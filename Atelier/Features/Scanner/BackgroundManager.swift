//
//  BackgroundManager.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 21/03/26.
//

import UIKit
import Vision
import CoreImage.CIFilterBuiltins

struct BackgroundManager {
    private static let sharedContext = CIContext(options: [.cacheIntermediates: false])
    
    static func processImage(
        _ image    : UIImage,
        targetRatio: CGFloat = 2.0/3.0,
        completion : @escaping (UIImage?) -> Void
    ) {
        removeBackground(from: image) { liftedImage in
            Task { @MainActor in
                guard let liftedImage = liftedImage else {
                    completion(nil)
                    return
                }
                
                let finalImage = centerAndCompose(
                    image: liftedImage,
                    targetRatio: targetRatio
                )
                
                completion(finalImage)
            }
        }
    }
    
    private static func removeBackground(
        from image: UIImage,
        completion: @escaping (UIImage?) -> Void
    ) {
        guard let cgImage = image.cgImage else {
            completion(nil)
            return
        }
        
        let request = VNGenerateForegroundInstanceMaskRequest()
        request.revision = VNGenerateForegroundInstanceMaskRequestRevision1
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        let localContext = BackgroundManager.sharedContext
        
        Task.detached(priority: .userInitiated) {
            autoreleasepool {
                do {
                    try handler.perform([request])
                    
                    guard let result = request.results?.first else {
                        completion(nil)
                        return
                    }
                    
                    let outputCVPixelBuffer = try result.generateMaskedImage(
                        ofInstances             : result.allInstances,
                        from                    : handler,
                        croppedToInstancesExtent: false
                    )
                    
                    let ciImage = CIImage(cvPixelBuffer: outputCVPixelBuffer)
                    
                    guard let finalCGImage = localContext.createCGImage(ciImage, from: ciImage.extent) else {
                        completion(nil)
                        return
                    }
                    
                    let liftedImage = UIImage(
                        cgImage    : finalCGImage,
                        scale      : image.scale,
                        orientation: image.imageOrientation
                    )
                    
                    completion(liftedImage)
                    
                } catch {
                    print("Vision Error: \(error)")
                    completion(nil)
                }
            }
        }
    }
    
    private static func centerAndCompose(
        image: UIImage,
        targetRatio: CGFloat
    ) -> UIImage? {
        guard let ciBase = CIImage(image: image) else { return nil }
        
        let sourceSize = image.size
        let canvasSide = max(sourceSize.width, sourceSize.height)
        let canvasSize = CGSize(width: canvasSide, height: canvasSide / targetRatio)
        
        let xOffset = (canvasSize.width - sourceSize.width) / 2
        let yOffset = (canvasSize.height - sourceSize.height) / 2
        let transform = CGAffineTransform(translationX: xOffset, y: yOffset)
        let positionedSubject = ciBase.transformed(by: transform)
        
        let shadowMatrix = CIFilter.colorMatrix()
        shadowMatrix.inputImage = positionedSubject
        shadowMatrix.rVector = CIVector(x: 0, y: 0, z: 0, w: 0)
        shadowMatrix.gVector = CIVector(x: 0, y: 0, z: 0, w: 0)
        shadowMatrix.bVector = CIVector(x: 0, y: 0, z: 0, w: 0)
        shadowMatrix.aVector = CIVector(x: 0, y: 0, z: 0, w: 0.15)
        shadowMatrix.biasVector = CIVector(x: 0, y: 0, z: 0, w: 0)
        
        let blur = CIFilter.gaussianBlur()
        blur.inputImage = shadowMatrix.outputImage
        blur.radius = 12
        
        let shadowOffset = CGAffineTransform(translationX: 0, y: -4)
        guard let shadow = blur.outputImage?.transformed(by: shadowOffset) else { return nil }
        
        let subjectWithShadow = positionedSubject.composited(over: shadow)
        
        let extent = positionedSubject.extent
        let centerRect = CGRect(x: extent.midX - 10, y: extent.midY - 10, width: 20, height: 20)
        
        var dynamicCenterColor = CIColor(red: 0.35, green: 0.32, blue: 0.30)
        
        if let averageFilter = CIFilter(name: "CIAreaAverage") {
            averageFilter.setValue(positionedSubject, forKey: kCIInputImageKey)
            averageFilter.setValue(CIVector(cgRect: centerRect), forKey: kCIInputExtentKey)
            
            if let outputImage = averageFilter.outputImage {
                var bitmap = [UInt8](repeating: 0, count: 4)

                sharedContext.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)
                

                dynamicCenterColor = CIColor(
                    red: CGFloat(bitmap[0]) / 255.0,
                    green: CGFloat(bitmap[1]) / 255.0,
                    blue: CGFloat(bitmap[2]) / 255.0
                )
            }
        }
        
        let edgeColor = CIColor(
            red: dynamicCenterColor.red * 0.15,
            green: dynamicCenterColor.green * 0.15,
            blue: dynamicCenterColor.blue * 0.15
        )
       
        
        let centerX = canvasSize.width / 2.0
        let centerY = canvasSize.height / 2.0
        let centerVector = CIVector(x: centerX, y: centerY)
        let outerRadius = max(canvasSize.width, canvasSize.height) * 0.85
        
        guard let radialGradient = CIFilter(name: "CIRadialGradient") else {
            return nil
        }
        
        radialGradient.setValue(centerVector, forKey: "inputCenter")
        radialGradient.setValue(0.0, forKey: "inputRadius0")
        radialGradient.setValue(outerRadius, forKey: "inputRadius1")
        radialGradient.setValue(dynamicCenterColor, forKey: "inputColor0")
        radialGradient.setValue(edgeColor, forKey: "inputColor1")
        
        guard let gradientOutput = radialGradient.outputImage else { return nil }
        let bg = gradientOutput.cropped(to: CGRect(origin: .zero, size: canvasSize))
        
        
        let finalCI = subjectWithShadow.composited(over: bg)
        guard let finalCG = sharedContext.createCGImage(finalCI, from: bg.extent) else { return nil }
        
        return UIImage(cgImage: finalCG)
    }
}
