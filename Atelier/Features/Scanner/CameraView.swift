import SwiftUI
import CoreML
import PhotosUI
import UniformTypeIdentifiers

struct TempImageFile: Transferable {
    let url: URL
    
    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(contentType: .image) { _ in
            fatalError("Export not supported")
            
        } importing: { received in
            let ext = received.file.pathExtension.isEmpty ? "heic" : received.file.pathExtension
            
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).\(ext)")
            
            try? FileManager.default.removeItem(at: tempURL)
            try FileManager.default.copyItem(at: received.file, to: tempURL)
            
            return TempImageFile(url: tempURL)
        }
    }
}

struct CameraView: UIViewControllerRepresentable {
    
    @Environment(\.dismiss)
    var dismiss
    
    @Environment(CaptureManager.self)
    var captureManager: CaptureManager
    
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
    
    var mode: CameraMode
    
    func makeCoordinator() -> Coordinator {
        Coordinator(
            self,
            manager: captureManager
        )
    }
    
    func makeUIViewController(context: Context) -> CameraViewController {
        let controller = CameraViewController()
        controller.delegate    = context.coordinator
        controller.currentMode = mode
        
        context.coordinator.viewController = controller
        return controller
    }
    
    func updateUIViewController(
        _ uiViewController: CameraViewController,
        context: Context
    ) {
        context.coordinator.parent = self
        
        uiViewController.updateFlashMode(isFlashEnabled)
        uiViewController.updateCameraPosition(isFront: isUsingFrontCamera)
        
        if capturePhotoTrigger {
            Task { @MainActor in self.capturePhotoTrigger = false }
            uiViewController.takePhoto()
        }
        
        if let item = selectedPhotoPicker {
            Task { @MainActor in self.selectedPhotoPicker = nil }
            context.coordinator.handlePhotoSelection(item)
        }
    }
    
    internal
    final class Coordinator: NSObject, CameraViewControllerDelegate {
        var parent : CameraView
        var manager: CaptureManager
        
        weak var viewController: CameraViewController?
        private var isProcessing = false
        
        init(
            _ parent: CameraView,
            manager : CaptureManager
        ) {
            self.parent  = parent
            self.manager = manager
        }
        
        
        
        @MainActor
        private func processWorkflow(originalImage: UIImage) {
            guard !isProcessing, let vc = viewController else { return }
            
            isProcessing = true
            parent.progress = 10.0
            
            let croppedImage = vc.cropImageTo2By3(image: originalImage)
            parent.progress = 30.0
            
            let needsBackgroundRemoval: Bool
            if case .photo(let remove) = parent.mode {
                needsBackgroundRemoval = remove
            } else {
                needsBackgroundRemoval = false
            }
            
            Task {
                if needsBackgroundRemoval {
                    parent.progress = 50.0
                    
                    if let finalImage = await BackgroundManager.processImage(croppedImage) {
                        finalizeImage(finalImage)
                        
                    } else {
                        isProcessing = false
                    }
                    
                } else {
                    finalizeImage(croppedImage)
                }
            }
        }
        
        @MainActor
        private func finalizeImage(_ image: UIImage) {
            parent.progress = 80.0
            
            if let data = image.heicData() {
                let savedImage = manager.savePhotoToDisk(data)
                
                if let filename = savedImage.filename,
                   let uiImage = savedImage.image {
                    parent.progress = 100.0
                    
                    parent.onImageCaptured(filename, uiImage)
                    parent.dismiss()
                }
            }
            isProcessing = false
        }
        
        
        
        func didTakePhoto(_ image: UIImage) {
            withAnimation {
                processWorkflow(originalImage: image)
            }
        }
        
        func handlePhotoSelection(_ item: PhotosPickerItem) {
            guard !isProcessing else { return }
            
            Task { @MainActor in
                defer { isProcessing = false }
                do {
                    if let file = try await item.loadTransferable(type: TempImageFile.self) {
                        defer { try? FileManager.default.removeItem(at: file.url) }
                        
                        let options: [CFString: Any] = [
                            kCGImageSourceCreateThumbnailFromImageAlways: true,
                            kCGImageSourceThumbnailMaxPixelSize: 2048,
                            kCGImageSourceCreateThumbnailWithTransform: true
                        ]
                        
                        guard let source = CGImageSourceCreateWithURL(file.url as CFURL, nil),
                              let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary) else { return }
                        
                        let rawImage = UIImage(cgImage: cgImage)
                        processWorkflow(originalImage: rawImage)
                    }
                } catch {
                    print("Error loading: \(error)")
                }
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
    func didTakePhoto(_ image: UIImage)
    func didFindSymbols(_ symbols: [String])
    func didUpdateProgress(_ progress: Double)
}
