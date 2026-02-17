#if os(iOS)
import SwiftUI
import AVFoundation

struct CameraView: UIViewControllerRepresentable {
    var captureManager = CaptureManager()
    
    var onImageCaptured: ((String, UIImage) -> Void)
    @Environment(\.dismiss) var dismiss
    
    
    func makeUIViewController(context: Context) -> CameraViewController {
        let controller = CameraViewController()
        controller.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator { Coordinator(self) }
    
    class Coordinator: NSObject, CameraViewControllerDelegate {
        var parent: CameraView
        init(_ parent: CameraView) { self.parent = parent }
        
        func didTakePhoto(_ photoData: Data) {
            let result = self.parent.captureManager.savePhotoToDisk(photoData)
            
            if let filename = result.filename, let image = result.image {
                self.parent.onImageCaptured(filename, image)
                self.parent.dismiss()
            }
        }
    }
}

protocol CameraViewControllerDelegate: AnyObject {
    func didTakePhoto(_ photoData: Data)
}

class CameraViewController: UIViewController {
    weak var delegate: CameraViewControllerDelegate?
    
    private let captureSession = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    private var previewLayer: AVCaptureVideoPreviewLayer!
    
    private let captureButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkPermissions()
        setupUI()
    }
    
    private func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: setupCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { allowed in
                if allowed { DispatchQueue.main.async { self.setupCamera() } }
            }
        default: break
        }
    }
    
    private func setupCamera() {
        captureSession.beginConfiguration()
        captureSession.sessionPreset = .photo
        
        // 1. CERCA LA CAMERA GIUSTA (LiDAR > Triple > Dual > Wide)
        let discovery = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInLiDARDepthCamera, .builtInTripleCamera, .builtInDualWideCamera, .builtInWideAngleCamera],
            mediaType: .video,
            position: .back
        )
        
        guard let device = discovery.devices.first,
              let input = try? AVCaptureDeviceInput(device: device) else {
            print("❌ Nessuna camera valida trovata")
            return
        }
        
        if captureSession.canAddInput(input) { captureSession.addInput(input) }
        if captureSession.canAddOutput(photoOutput) { captureSession.addOutput(photoOutput) }
        
        // 2. CONFIGURAZIONE CRITICA PER IL 3D
        photoOutput.isHighResolutionCaptureEnabled = true
        // Attiva la profondità se disponibile (senza questo, il 3D viene male)
        if photoOutput.isDepthDataDeliverySupported {
            photoOutput.isDepthDataDeliveryEnabled = true
            // Priorità alla qualità, non alla velocità
            photoOutput.maxPhotoQualityPrioritization = .quality
        }
        
        captureSession.commitConfiguration()
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        view.layer.addSublayer(previewLayer)
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
        }
    }
    
    private func setupUI() {
        captureButton.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        captureButton.layer.cornerRadius = 40
        captureButton.backgroundColor = .white
        captureButton.layer.borderWidth = 4
        captureButton.layer.borderColor = UIColor.black.cgColor
        
        captureButton.center = CGPoint(
            x: view.bounds.midX,
            y: view.bounds.height - 250
        )
        
        captureButton.addTarget(
            self,
            action: #selector(takePhoto),
            for: .touchUpInside
        )
        
        view.addSubview(captureButton)
    }
    
    @objc private func takePhoto() {
        // 3. SETTINGS PER LO SCATTO (HEIC + DEPTH)
        var settings = AVCapturePhotoSettings()
        
        // Usa HEIC se disponibile (gestisce meglio i layer di profondità)
        if photoOutput.availablePhotoCodecTypes.contains(.hevc) {
            settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.hevc])
        }
        
        // Incorpora la profondità NEL file immagine
        if photoOutput.isDepthDataDeliverySupported {
            settings.isDepthDataDeliveryEnabled = true
            settings.embedsDepthDataInPhoto = true
            settings.isPortraitEffectsMatteDeliveryEnabled = false
        }
        
        settings.flashMode = .off
        // Alta risoluzione
        settings.photoQualityPrioritization = .quality
        
        photoOutput.capturePhoto(with: settings, delegate: self)
        
        // Feedback visivo
        let flash = UIView(frame: view.bounds)
        flash.backgroundColor = .black
        flash.alpha = 0
        view.addSubview(flash)
        UIView.animate(withDuration: 0.1, animations: { flash.alpha = 0.5 }) { _ in flash.removeFromSuperview() }
    }
    
    
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("❌ Errore scatto: \(error)")
            return
        }
        
        // Ottieni i dati grezzi (contengono EXIF + Depth + Gravity)
        guard let data = photo.fileDataRepresentation() else { return }
        delegate?.didTakePhoto(data)
    }
}

#endif
