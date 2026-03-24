//
//  CameraViewController.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 21/03/26.
//

import UIKit
import AVFoundation
import Vision
import CoreML

class CameraViewController: UIViewController, AVCapturePhotoCaptureDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {
    weak var delegate: CameraViewControllerDelegate?
        
    var currentMode: CameraMode = .photo(removeBackground: false)
    
    private var visionModel: VNCoreMLModel?
    private var overlayLayer = CAShapeLayer()
    private let captureSession = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    private let videoOutput = AVCaptureVideoDataOutput()
    private var previewLayer: AVCaptureVideoPreviewLayer!
    
    private var symbolsFounded: Set<String> = []
    private var isTimerStarted: Bool = false
    private var timerTask: Task<Void, Never>?
    
    private var currentFlashMode: AVCaptureDevice.FlashMode = .off
    private var isCurrentlyFrontCamera = false
        
    private var progressShoting: Double = 0.0 {
        didSet {
            delegate?.didUpdateProgress(progressShoting)
        }
    }
    
    private lazy var detectionRequest: VNCoreMLRequest? = {
        guard let visionModel = self.visionModel else { return nil }
        return VNCoreMLRequest(model: visionModel)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            let model = try LaundryIcons(
                configuration: MLModelConfiguration()
            ).model
            
            self.visionModel = try VNCoreMLModel(for: model)
            
        } catch {
            print("Error: Impossible load MLModel")
        }
        
        checkPermissions()
        setupUI()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        timerTask?.cancel()
        
        if captureSession.isRunning {
            
            Task.detached(priority: .userInitiated) { [weak self] in
                await self?.captureSession.stopRunning()
            }
        }
    }
    
    private func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized:
                setupCamera()
                
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) { allowed in
                    if allowed {
                        Task { @MainActor in self.setupCamera() }
                    }
                }
                
            default:
                break
        }
    }
    
    private func setupCamera(position: AVCaptureDevice.Position = .back) {
        guard !captureSession.isRunning else { return }
        
        captureSession.beginConfiguration()
        captureSession.sessionPreset = .photo
        
        configureInput(for: position)
        configureOutputs()
        
        captureSession.commitConfiguration()
        
        if previewLayer == nil {
            previewLayer = AVCaptureVideoPreviewLayer(
                session: captureSession
            )
            
            previewLayer.videoGravity = .resizeAspectFill
            previewLayer.frame        = view.bounds
            
            view.layer.insertSublayer(previewLayer, at: 0)
        }
        
        Task.detached(priority: .userInitiated) { [weak self] in
            await self?.captureSession.startRunning()
        }
    }
    
    private func configureInput(for position: AVCaptureDevice.Position) {
        if let currentInput = captureSession.inputs.first as? AVCaptureDeviceInput {
            captureSession.removeInput(currentInput)
        }
        
        let deviceTypes: [AVCaptureDevice.DeviceType] = position == .back
        ? [.builtInLiDARDepthCamera, .builtInTripleCamera, .builtInDualWideCamera, .builtInWideAngleCamera]
        : [.builtInWideAngleCamera]
        
        let discovery = AVCaptureDevice.DiscoverySession(
            deviceTypes: deviceTypes,
            mediaType  : .video,
            position   : position
        )
        
        guard let device = discovery.devices.first,
              let input = try? AVCaptureDeviceInput(device: device) else {
            print("Camere not found")
            return
        }
        
        if captureSession.canAddInput(input) {
            captureSession.addInput(input)
        }
    }
    
    private func configureOutputs() {
        switch self.currentMode {
            case .photo:
                if self.captureSession.canAddOutput(self.photoOutput) {
                    self.captureSession.addOutput(self.photoOutput)
                    
                    if self.photoOutput.isDepthDataDeliverySupported {
                        self.photoOutput.isDepthDataDeliveryEnabled = true
                        
                        self.photoOutput.maxPhotoQualityPrioritization = .quality
                        
                    }
                }
                
            case .recognizeSymbols:
                if self.captureSession.canAddOutput(self.videoOutput) {
                    self.captureSession.addOutput(self.videoOutput)
                    
                    let videoQueue = DispatchQueue(
                        label: "videoQueue",
                        qos: .userInteractive
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
    }
    
    private func setupUI() {
        self.overlayLayer.frame = view.bounds
        view.layer.addSublayer(self.overlayLayer)
    }
    
    // MARK: - Public method call on SwiftUI
    
    func takePhoto() {
        var settings = AVCapturePhotoSettings()
        
        if photoOutput.availablePhotoCodecTypes.contains(.hevc) {
            settings = AVCapturePhotoSettings(
                format: [AVVideoCodecKey: AVVideoCodecType.hevc]
            )
        }
        
        settings.flashMode = self.currentFlashMode
        settings.photoQualityPrioritization = .quality
        
        photoOutput.capturePhoto(
            with    : settings,
            delegate: self
        )
        
        let flash = UIView(frame: view.bounds)
        
        flash.backgroundColor = .black
        flash.alpha = 0
        
        view.addSubview(flash)
        
        UIView.animate(
            withDuration: 0.1,
            animations: { flash.alpha = 1 }
        ) { _ in
            
            UIView.animate(
                withDuration: 0.1,
                animations: { flash.alpha = 0 }
            ) { _ in
                flash.removeFromSuperview()
            }
        }
    }
    
    func updateFlashMode(_ enabled: Bool) {
        self.currentFlashMode = enabled ? .on : .off
    }
    
    func updateCameraPosition(isFront: Bool) {
        guard isFront != isCurrentlyFrontCamera else { return }
        isCurrentlyFrontCamera = isFront
        
        Task.detached(priority: .userInitiated) { [weak self] in
            guard let self = self else { return }
            
            await self.captureSession.beginConfiguration()
            await self.configureInput(for: isFront ? .front : .back)
            await self.captureSession.commitConfiguration()
        }
    }
    
    // MARK: - Delegate
    
    func captureOutput(
        _         output      : AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from      connection  : AVCaptureConnection
    ) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        analizeImage(pixelBuffer) { results in
            
            if let symbols = results,
                  !symbols.isEmpty {
                Task { @MainActor in
                    self.drawRectangle(symbols)
                }
            }
        }
    }
    
    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        if let _ = error { return }
        
        guard let data = photo.fileDataRepresentation() else { return }
        
        Task.detached(priority: .userInitiated) {
            let options: [CFString: Any] = [
                kCGImageSourceCreateThumbnailFromImageAlways: true,
                kCGImageSourceThumbnailMaxPixelSize         : 2048,
                kCGImageSourceCreateThumbnailWithTransform  : true
            ]
            
            guard let source = CGImageSourceCreateWithData(data as CFData, nil),
                  let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary) else { return }
            
            let downsampledImage = UIImage(cgImage: cgImage)
            
            Task { @MainActor in
                self.delegate?.didTakePhoto(downsampledImage)
            }
        }
    }
    
    func cropImageTo2By3(image: UIImage) -> UIImage {
        let contextSize = image.size
        let targetRatio: CGFloat = 2.0 / 3.0
        
        var cropWidth: CGFloat
        var cropHeight: CGFloat
        
        if contextSize.width / contextSize.height > targetRatio {
            cropHeight = contextSize.height
            cropWidth = contextSize.height * targetRatio
            
        } else {
            cropWidth = contextSize.width
            cropHeight = contextSize.width / targetRatio
        }
        
        let xOffset = (contextSize.width - cropWidth) / 2
        let yOffset = (contextSize.height - cropHeight) / 2
        
        let cropRect = CGRect(x: xOffset, y: yOffset, width: cropWidth, height: cropHeight)
        
        guard let cgImage = image.cgImage?.cropping(to: cropRect) else {
            return image
        }
        
        return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
    }
    
    private func analizeImage(
        _ pixelBuffer: CVPixelBuffer,
        completion: @escaping ([VNRecognizedObjectObservation]?) -> Void
    ) {
        guard let request = self.detectionRequest else {
            completion(nil)
            return
        }
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        
        Task.detached(priority: .userInitiated) {
            autoreleasepool {
                do {
                    try handler.perform([request])
                    let result = request.results as? [VNRecognizedObjectObservation]
                    Task { @MainActor in completion(result) }
                    
                } catch {
                    Task { @MainActor in completion(nil) }
                }
            }
        }
    }
    
    private func drawRectangle(_ items: [VNRecognizedObjectObservation]) {
        self.overlayLayer.sublayers?.forEach { $0.removeFromSuperlayer() }
        
        for item in items {
            guard let label = item.labels.first, label.confidence > 0.90 else { continue }
            
            self.symbolsFounded.insert(label.identifier)
            let visionRect = item.boundingBox
            let rectRaddrizzato = CGRect(x: visionRect.minX, y: 1.0 - visionRect.maxY, width: visionRect.width, height: visionRect.height)
            
            let perfectRect = self.previewLayer.layerRectConverted(fromMetadataOutputRect: rectRaddrizzato)
            
            let boxLayer = CAShapeLayer()
            boxLayer.frame = perfectRect
            boxLayer.borderWidth = 3
            boxLayer.borderColor = UIColor.green.cgColor
            boxLayer.backgroundColor = UIColor.clear.cgColor
            boxLayer.cornerRadius = 8
            self.overlayLayer.addSublayer(boxLayer)
            
            if !self.symbolsFounded.isEmpty && !self.isTimerStarted {
                self.isTimerStarted = true
                
                timerTask = Task { @MainActor in
                    try? await Task.sleep(for: .seconds(2))
                    guard !Task.isCancelled else { return } 
                    
                    self.captureSession.stopRunning()
                    self.delegate?.didFindSymbols(Array(self.symbolsFounded))
                }
            }
        }
    }
}
