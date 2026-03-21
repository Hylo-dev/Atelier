#if os(iOS)
import SwiftUI
import CoreML

struct CameraView: UIViewControllerRepresentable {
    
    @Environment(\.dismiss)
    var dismiss
    
    @Binding
    var isFlashEnabled: Bool
    
    @Binding
    var isUsingFrontCamera: Bool
    
    @Binding
    var capturePhotoTrigger: Bool
    
    var onImageCaptured  : ((String, UIImage) -> Void)
    var onSymbolsCaptured: (([String]) -> Void)?
    
    var captureManager: CaptureManager = CaptureManager()
    var mode: CameraMode
    
    func makeUIViewController(context: Context) -> CameraViewController {
        let controller = CameraViewController()
        controller.delegate = context.coordinator
        controller.currentMode = self.mode
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {

        uiViewController.updateFlashMode(isFlashEnabled)
        uiViewController.updateCameraPosition(isFront: isUsingFrontCamera)
        
        if capturePhotoTrigger {
            Task {
                uiViewController.takePhoto()
                self.capturePhotoTrigger = false 
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, CameraViewControllerDelegate {
        var parent: CameraView
        
        init(_ parent: CameraView) {
            self.parent = parent
        }
        
        func didTakePhoto(_ photoData: Data) {
            let result = self.parent.captureManager.savePhotoToDisk(photoData)
            
            if let filename = result.filename, let image = result.image {
                self.parent.onImageCaptured(filename, image)
                self.parent.dismiss()
            }
        }
        
        func didFindSymbols(_ symbols: [String]) {
            self.parent.onSymbolsCaptured?(symbols)
            self.parent.dismiss()
        }
    }
}

protocol CameraViewControllerDelegate: AnyObject {
    func didTakePhoto(_ photoData: Data)
    func didFindSymbols(_ symbols: [String])
}
#endif
