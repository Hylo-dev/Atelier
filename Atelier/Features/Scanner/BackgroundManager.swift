//
//  BackgroundManager.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 21/03/26.
//

import UIKit
import Vision

struct BackgroundManager {
    
    static func processImage(
        _ image      : UIImage,
          targetRatio: CGFloat = 2.0/3.0,
          completion : @escaping (UIImage?) -> Void
    ) {
        
        removeBackground(from: image) { liftedImage in
            guard let liftedImage = liftedImage else {
                completion(nil)
                return
            }
            
            let finalImage = centerAndCompose(image: liftedImage, targetRatio: targetRatio)
            
            completion(finalImage)
        }
    }
    
    // MARK: - Private logic
    
    private static func removeBackground(
        from image     : UIImage,
             completion: @escaping (UIImage?) -> Void
    ) {
        guard let cgImage = image.cgImage else {
            completion(nil)
            return
        }
        
        let request = VNGenerateForegroundInstanceMaskRequest()
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
                
        Task.detached(priority: .userInitiated) {
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
                let context = CIContext()
                
                guard let finalCGImage = context.createCGImage(ciImage, from: ciImage.extent) else {
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
                print("Error on subject lifting process: \(error)")
                completion(nil)
            }
        }
    }
    
    private static func centerAndCompose(image: UIImage, targetRatio: CGFloat) -> UIImage {
        let sourceSize = image.size
        
        let canvasSide = max(sourceSize.width, sourceSize.height)
        let canvasSize = CGSize(width: canvasSide, height: canvasSide / targetRatio)
        
        let renderer = UIGraphicsImageRenderer(size: canvasSize)
        
        let finalImage = renderer.image { context in
            // UIColor.white.setFill(); context.fill(CGRect(origin: .zero, size: canvasSize))
            
            let xOffset = (canvasSize.width - sourceSize.width) / 2
            let yOffset = (canvasSize.height - sourceSize.height) / 2
            let drawRect = CGRect(x: xOffset, y: yOffset, width: sourceSize.width, height: sourceSize.height)
            
            image.draw(in: drawRect)
        }
        
        return finalImage
    }
}
