import SwiftUI
import AVFoundation

enum BarcodeScannerResult {
    case success(String)
    case failure(Error)
}

struct BarcodeScanner: UIViewRepresentable {
    let onResult: (BarcodeScannerResult) -> Void
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        
        guard AVCaptureDevice.authorizationStatus(for: .video) == .authorized else {
            checkCameraPermission { authorized in
                if !authorized {
                    onResult(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Camera access denied"])))
                }
            }
            return view
        }
        
        setupCaptureSession(view: view, context: context)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
    
    private func checkCameraPermission(completion: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            completion(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                completion(granted)
            }
        case .denied, .restricted:
            completion(false)
        @unknown default:
            completion(false)
        }
    }
    
    private func setupCaptureSession(view: UIView, context: Context) {
        let captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video),
              let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice) else {
            onResult(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to setup camera"])))
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if captureSession.canAddInput(videoInput) && captureSession.canAddOutput(metadataOutput) {
            captureSession.addInput(videoInput)
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(context.coordinator, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.ean13, .ean8] // Support both ISBN-13 and ISBN-10
            
            let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.frame = view.layer.bounds
            previewLayer.videoGravity = .resizeAspectFill
            view.layer.addSublayer(previewLayer)
            
            DispatchQueue.global(qos: .userInitiated).async {
                captureSession.startRunning()
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onResult: onResult)
    }
    
    class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        let onResult: (BarcodeScannerResult) -> Void
        var lastScanTime = Date.distantPast
        let scanInterval: TimeInterval = 2.0
        
        init(onResult: @escaping (BarcodeScannerResult) -> Void) {
            self.onResult = onResult
        }
        
        func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            if let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
               let code = metadataObject.stringValue,
               Date().timeIntervalSince(lastScanTime) > scanInterval {
                lastScanTime = Date()
                onResult(.success(code))
            }
        }
    }
}
