import SwiftUI
import AVFoundation
import UserNotifications

struct BarcodeScannerView: View {
    @ObservedObject var library: Library
    @State private var isShowingScanner = false
    @State private var manualISBN = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isManualEntry = false
    @State private var cameraPermissionStatus: AVAuthorizationStatus = .notDetermined
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            BackgroundView()
            
            VStack {
                if isManualEntry {
                    manualEntryView
                } else {
                    switch cameraPermissionStatus {
                    case .authorized:
                        scannerPortalView
                    case .notDetermined:
                        requestCameraAccess
                    case .denied, .restricted:
                        deniedCameraAccess
                    @unknown default:
                        Text("Unknown camera authorization status")
                    }
                }
            }
        }
        .navigationTitle(isManualEntry ? "Manual Entry" : "Scan Book")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    withAnimation {
                        isManualEntry.toggle()
                    }
                } label: {
                    Image(systemName: isManualEntry ? "barcode.viewfinder" : "keyboard")
                }
            }
        }
        .alert("Error", isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
        .onAppear {
            updateCameraPermissionStatus()
        }
    }
    
    private var scannerPortalView: some View {
        GeometryReader { geometry in
            ZStack {
                // Camera view
                BarcodeScanner { result in
                    switch result {
                    case .success(let isbn):
                        handleISBN(isbn)
                    case .failure(let error):
                        showError(error.localizedDescription)
                    }
                }
                .ignoresSafeArea()
                
                // Scanning overlay
                VStack {
                    Spacer()
                    
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.green, style: StrokeStyle(lineWidth: 4, dash: [10, 10]))
                        .frame(width: geometry.size.width * 0.8, height: 200)
                        .overlay(
                            VStack {
                                Text("Align barcode within the frame")
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.black.opacity(0.5))
                                    .cornerRadius(10)
                                
                                Button(action: {
                                    withAnimation {
                                        isManualEntry = true
                                    }
                                }) {
                                    Text("Enter ISBN Manually")
                                        .foregroundColor(.white)
                                        .padding()
                                        .background(Color.blue.opacity(0.7))
                                        .cornerRadius(10)
                                }
                                .padding(.top)
                            }
                            .offset(y: 120)
                        )
                    
                    Spacer()
                }
                .edgesIgnoringSafeArea(.all)
            }
        }
    }
    
    private var deniedCameraAccess: some View {
        VStack(spacing: 20) {
            Image(systemName: "camera.fill")
                .font(.system(size: 50))
                .foregroundColor(.red)
            
            Text("Camera Access Denied")
                .font(.title2)
            
            Text("Please enable camera access in Settings to scan book barcodes")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            Button("Open Settings") {
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
    
    private var requestCameraAccess: some View {
        VStack(spacing: 20) {
            Image(systemName: "camera.fill")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            
            Text("Camera Access Required")
                .font(.title2)
            
            Text("Please allow camera access to scan book barcodes")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            Button("Allow Camera Access") {
                requestCameraPermission()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
    
    private var manualEntryView: some View {
        VStack(spacing: 20) {
            Text("Enter ISBN")
                .font(.headline)
            
            TextField("ISBN", text: $manualISBN)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numberPad)
                .padding()
            
            Button("Submit") {
                if manualISBN.count == 13 || manualISBN.count == 10 {
                    handleISBN(manualISBN)
                } else {
                    showError("ISBN must be 10 or 13 digits")
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(manualISBN.isEmpty)
            
            Spacer()
        }
        .padding()
    }
    
    private func updateCameraPermissionStatus() {
        cameraPermissionStatus = AVCaptureDevice.authorizationStatus(for: .video)
        print("Camera permission status: \(cameraPermissionStatus.rawValue)")
    }
    
    private func requestCameraPermission() {
        print("Requesting camera permission...")
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                print("Camera permission response: \(granted)")
                updateCameraPermissionStatus()
                if !granted {
                    showError("Camera access denied")
                }
            }
        }
    }
    
    private func handleISBN(_ isbn: String) {
        Task {
            do {
                let book = try await GoogleBooksService().fetchBookDetails(isbn: isbn)
                await MainActor.run {
                    library.addBook(book)
                    sendBookAddedNotification(book: book)
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    showError(error.localizedDescription)
                }
            }
        }
    }
    
    private func sendBookAddedNotification(book: Book) {
        // Request notification permissions if not already granted
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted {
                let content = UNMutableNotificationContent()
                content.title = "Book Added to Library"
                content.body = "\(book.title) by \(book.author) has been added to your library."
                content.sound = .default
                
                // Create a trigger for immediate notification
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                
                // Create the request
                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                
                // Add the request to the notification center
                UNUserNotificationCenter.current().add(request)
            }
        }
    }
    
    private func showError(_ message: String) {
        alertMessage = message
        showingAlert = true
    }
}

#Preview {
    NavigationView {
        BarcodeScannerView(library: Library())
    }
}
