#if os(iOS)
import SwiftUI
import CoreML
import PhotosUI

struct CameraView: UIViewControllerRepresentable {
    
    @Environment(\.dismiss)
    var dismiss
    
    @Binding
    var isFlashEnabled: Bool
    
    @Binding
    var isUsingFrontCamera: Bool
    
    @Binding
    var capturePhotoTrigger: Bool
    
    @Binding
    var progress: Double
    
    @Binding
    var selectedPhotoPicker: PhotosPickerItem?
    
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
    
    func updateUIViewController(
        _ uiViewController: CameraViewController,
        context: Context
    ) {

        uiViewController.updateFlashMode(isFlashEnabled)
        uiViewController.updateCameraPosition(isFront: isUsingFrontCamera)
        
        if let photoItem = selectedPhotoPicker {
            Task { @MainActor in
                do {
                    if let data = try await photoItem.loadTransferable(
                        type: Data.self
                    ) {
                        let result = self.captureManager.savePhotoToDisk(data)
                        
                        if let filename = result.filename,
                            let image = result.image {
                            
                            self.onImageCaptured(filename, image)
                            self.dismiss()
                        }
                    }
                    
                } catch {
                    print("Error on load photo: \(error)")
                }
                
                self.selectedPhotoPicker = nil
            }
        }
        
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
        
        func didUpdateProgress(_ progress: Double) {
            withAnimation(.easeInOut) {
                parent.progress = progress
            }
        }
    }
}

protocol CameraViewControllerDelegate: AnyObject {
    func didTakePhoto(_ photoData: Data)
    func didFindSymbols(_ symbols: [String])
    func didUpdateProgress(_ progress: Double)
}
#endif
