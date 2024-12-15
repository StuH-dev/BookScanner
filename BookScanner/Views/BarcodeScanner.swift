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
        print("BarcodeScanner: makeUIView called")
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video),
              let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice) else {
            print("BarcodeScanner: Failed to setup video capture device")
            onResult(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to setup camera"])))
            return view
        }
        
        let captureSession = AVCaptureSession()
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
            
            // Update preview layer frame when view is resized
            view.layer.addSublayer(previewLayer)
            view.backgroundColor = .black
            
            DispatchQueue.global(qos: .userInitiated).async {
                print("BarcodeScanner: Starting capture session")
                captureSession.startRunning()
            }
            
            print("BarcodeScanner: Setup completed successfully")
        } else {
            print("BarcodeScanner: Failed to setup capture session")
            onResult(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to setup camera"])))
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if let previewLayer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
            previewLayer.frame = uiView.layer.bounds
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
                print("BarcodeScanner: Scanned code: \(code)")
                onResult(.success(code))
            }
        }
    }
}
