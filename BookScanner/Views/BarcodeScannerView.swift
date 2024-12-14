import SwiftUI
import AVFoundation

struct BarcodeScannerView: View {
    @ObservedObject var library: Library
    @State private var isShowingScanner = false
    @State private var manualISBN = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isManualEntry = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            if isManualEntry {
                manualEntryView
            } else {
                if AVCaptureDevice.authorizationStatus(for: .video) == .authorized {
                    BarcodeScanner { result in
                        switch result {
                        case .success(let isbn):
                            handleISBN(isbn)
                        case .failure(let error):
                            showError(error.localizedDescription)
                        }
                    }
                    .ignoresSafeArea()
                } else {
                    requestCameraAccess
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
            checkCameraPermission()
        }
    }
    
    private var requestCameraAccess: some View {
        VStack(spacing: 20) {
            Image(systemName: "camera.fill")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            
            Text("Camera Access Required")
                .font(.title2)
            
            Text("Please allow camera access in Settings to scan book barcodes")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            Button("Request Access") {
                checkCameraPermission()
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
    
    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        isShowingScanner = true
                    } else {
                        showError("Camera access denied")
                    }
                }
            }
        case .restricted, .denied:
            showError("Camera access denied")
        case .authorized:
            isShowingScanner = true
        @unknown default:
            showError("Unknown camera authorization status")
        }
    }
    
    private func handleISBN(_ isbn: String) {
        Task {
            do {
                let book = try await GoogleBooksService().fetchBookDetails(isbn: isbn)
                await MainActor.run {
                    library.addBook(book)
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    showError(error.localizedDescription)
                }
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
