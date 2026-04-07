//
//  Heic+.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 07/04/2026.
//


import UIKit
import UniformTypeIdentifiers

extension UIImage {
    func heicData(compressionQuality: CGFloat = 0.7) -> Data? {
        let data = NSMutableData()
        // Definiamo il tipo di destinazione come HEIC
        guard let destination = CGImageDestinationCreateWithData(data, UTType.heic.identifier as CFString, 1, nil),
              let cgImage = self.cgImage else { return nil }
        
        // Impostiamo la qualità di compressione
        let options = [kCGImageDestinationLossyCompressionQuality: compressionQuality] as CFDictionary
        
        CGImageDestinationAddImage(destination, cgImage, options)
        
        guard CGImageDestinationFinalize(destination) else { return nil }
        return data as Data
    }
}
