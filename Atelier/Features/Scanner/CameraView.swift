#if os(iOS)
import SwiftUI
import AVFoundation
import Vision
import CoreML

struct CameraView: UIViewControllerRepresentable {
    
    @Environment(\.dismiss)
    var dismiss
    
    var onImageCaptured  : ((String, UIImage) -> Void)
    var onSymbolsCaptured: (([String]) -> Void)?
    
    var captureManager: CaptureManager = CaptureManager()
    var mode          : CameraMode
    
    func makeUIViewController(context: Context) -> CameraViewController {
        let controller         = CameraViewController()
        controller.delegate    = context.coordinator
        controller.currentMode = self.mode
        
        return controller
    }
    
    
    func updateUIViewController(
        _ uiViewController: CameraViewController,
        context: Context
    ) {  }
    
    
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
            
            if let filename = result.filename,
               let image    = result.image {
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
    func didTakePhoto  (_ photoData: Data)
    func didFindSymbols(_ symbols  : [String])
}

class CameraViewController: UIViewController, AVCapturePhotoCaptureDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {
    weak var delegate: CameraViewControllerDelegate?
    
    var currentMode: CameraMode = .photo
    
    private var visionModel: VNCoreMLModel?
    
    private var overlayLayer   = CAShapeLayer()
    private let captureSession = AVCaptureSession()
    private let photoOutput    = AVCapturePhotoOutput()
    private let videoOutput    = AVCaptureVideoDataOutput()
    private let captureButton  = UIButton()

    private var previewLayer: AVCaptureVideoPreviewLayer!
    
    private var symbolsFounded: Set<String> = []
    private var isTimerStarted: Bool        = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            let model = try LaundryIcons(
                configuration: MLModelConfiguration()
            ).model
            
            self.visionModel = try VNCoreMLModel(for: model)
        } catch {
            print("❌ Errore critico: Impossibile caricare il modello CoreML.")
        }
        
        checkPermissions()
        setupUI()
    }
    
    private func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: setupCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { allowed in
                if allowed {
                    Task { @MainActor in
                        self.setupCamera()
                    }
                }
            }
        default: break
        }
    }
    
    private func setupCamera() {
        captureSession.beginConfiguration()
        captureSession.sessionPreset = .photo
        
        // Camera order (LiDAR > Triple > Dual > Wide)
        let discovery = AVCaptureDevice.DiscoverySession(
            deviceTypes: [
                .builtInLiDARDepthCamera,
                .builtInTripleCamera,
                .builtInDualWideCamera,
                .builtInWideAngleCamera
            ],
            mediaType: .video,
            position: .back
        )
        
        guard let device = discovery.devices.first,
              let input = try? AVCaptureDeviceInput(device: device) else {
            print("❌ Nessuna camera valida trovata")
            return
        }
        
        if self.captureSession.canAddInput(input) {
            self.captureSession.addInput(input)
        }
        
        switch self.currentMode {
            case .photo:
                if self.captureSession.canAddOutput(self.photoOutput) {
                    self.captureSession.addOutput(self.photoOutput)
                    
                    if self.photoOutput.isDepthDataDeliverySupported {
                        self.photoOutput.isDepthDataDeliveryEnabled    = true
                        self.photoOutput.maxPhotoQualityPrioritization = .quality
                    }
                }
                
            case .recognizeSymbols:
                if self.captureSession.canAddOutput(self.videoOutput) {
                    self.captureSession.addOutput(self.videoOutput)
                    
                    let videoQueue = DispatchQueue(
                        label: "videoQueue",
                        qos  : .userInteractive
                    )
                    
                    self.videoOutput.setSampleBufferDelegate(
                        self,
                        queue: videoQueue
                    )
                    
                    self.videoOutput.alwaysDiscardsLateVideoFrames = true
                }
                
            case .create3DModel:
                break
        }

        captureSession.commitConfiguration()
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame        = view.bounds
        
        view.layer.addSublayer(previewLayer)
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
        }
    }
    
    private func setupUI() {
        self.overlayLayer.frame = view.bounds
        view.layer.addSublayer(self.overlayLayer)
        
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
        
        self.captureButton.isHidden = (currentMode != .photo)
        view.addSubview(captureButton)
    }
    
    @objc
    private func takePhoto() {
        var settings = AVCapturePhotoSettings()
        
        if photoOutput.availablePhotoCodecTypes.contains(.hevc) {
            settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.hevc])
        }
        
        if photoOutput.isDepthDataDeliverySupported {
            settings.isDepthDataDeliveryEnabled            = true
            settings.embedsDepthDataInPhoto                = true
            settings.isPortraitEffectsMatteDeliveryEnabled = false
        }
        
        settings.flashMode                  = .off
        settings.photoQualityPrioritization = .quality
        
        self.photoOutput.capturePhoto(with: settings, delegate: self)
        
        let flash = UIView(frame: view.bounds)
        
        flash.backgroundColor = .black
        flash.alpha           = 0
        
        view.addSubview(flash)
        
        UIView.animate(
            withDuration: 0.1,
            animations: { flash.alpha = 0.5 }
        ) { _ in flash.removeFromSuperview() }
    }
    
    func captureOutput(
        _         output      : AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from      connection  : AVCaptureConnection
    ) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        else { return }
        
        self.analizeImage(pixelBuffer) { results in
            if let symbols = results, !symbols.isEmpty {
                Task { @MainActor in self.drawRectangle(symbols) }
            }
        }
    }
    
    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        if let error = error {
            print("❌ Errore scatto: \(error)")
            return
        }
        
        guard let data = photo.fileDataRepresentation() else { return }
        delegate?.didTakePhoto(data)
    }
    
    private func analizeImage(
        _ pixelBuffer: CVPixelBuffer,
        completion   : @escaping ([VNRecognizedObjectObservation]?) -> Void
    ) {
        
        guard let visionModel = self.visionModel else {
            completion(nil); return
        }
        
        let request = VNCoreMLRequest(model: visionModel) { request, error in
            let result = request.results as? [VNRecognizedObjectObservation]
            Task { @MainActor in completion(result) }
        }
        
        
        let handler = VNImageRequestHandler(
            cvPixelBuffer: pixelBuffer,
            options      : [:]
        )
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
                
            } catch {
                print("Error to exec IA scan: \(error)")
                Task { @MainActor in completion(nil) }
            }
        }
    }
    
    private func drawRectangle(
        _ items: [VNRecognizedObjectObservation]
    ) {
        self.overlayLayer.sublayers?.forEach { $0.removeFromSuperlayer() }
        
        for item in items {
            guard let label = item.labels.first,
                  label.confidence > 0.90
            else { continue }
            
            self.symbolsFounded.insert(label.identifier)
            let visionRect = item.boundingBox
            
            let rectRaddrizzato = CGRect(
                x     : visionRect.minX,
                y     : 1.0 - visionRect.maxY,
                width : visionRect.width,
                height: visionRect.height
            )
            
            let perfectRect = self.previewLayer.layerRectConverted(fromMetadataOutputRect: rectRaddrizzato)
            
            let boxLayer = CAShapeLayer()
            boxLayer.frame           = perfectRect
            boxLayer.borderWidth     = 3
            boxLayer.borderColor     = UIColor.green.cgColor
            boxLayer.backgroundColor = UIColor.clear.cgColor
            boxLayer.cornerRadius    = 8
            
            self.overlayLayer.addSublayer(boxLayer)
            
            if !self.symbolsFounded.isEmpty && !self.isTimerStarted {
                self.isTimerStarted = true
                
                Task { @MainActor in
                    try? await Task.sleep(for: .seconds(2))
                    
                    self.captureSession.stopRunning()
                    self.delegate?.didFindSymbols(Array(self.symbolsFounded))
                }
            }
        }
    }
}
#endif
