//
//  ImageStorage.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 16/02/26.
//

import UIKit

enum ImageSaveError: Error {
    case conversionFailed
    case folderNotFound
    case writeFailed(String)
    
    var localizedDescription: String {
        return switch self {
            case .conversionFailed:
                "We couldn't process this photo. Please try taking it again."
                
            case .folderNotFound:
                "Something went wrong while accessing your phone's storage. Please restart the app."
                
            case .writeFailed(let details):
                
                if details.contains("out of space") {
                    "Your iPhone storage is full. Please make some space to save new items."

                } else {
                    "The photo couldn't be saved. Please try again in a moment."
                }
                
        }
    }
}

struct ImageStorage {
    static func saveImage(
        _ image       : UIImage,
          maxDimension: CGFloat = 1024
    ) -> Result<String, ImageSaveError> {
        
        let size = image.size
        let aspectRatio = size.width / size.height
        var newSize: CGSize
        
        if size.width > size.height {
            newSize = CGSize(width: maxDimension, height: maxDimension / aspectRatio)
        } else {
            newSize = CGSize(width: maxDimension * aspectRatio, height: maxDimension)
        }
        
        if size.width <= maxDimension && size.height <= maxDimension {
            newSize = size
        }
        
        let format = UIGraphicsImageRendererFormat()
        format.opaque = true
        format.scale  = 1.0
        
        let renderer = UIGraphicsImageRenderer(
            size  : newSize,
            format: format
        )
        let resizedImage = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
        
        guard let data = resizedImage.heicData() else {
            print("Errore: Impossible convert to HEIC")
            return .failure(.conversionFailed)
        }
        
        let sizeKB = Double(data.count) / 1024.0
        let sizeMB = sizeKB / 1024.0
        
        print("File HEIC Size: \(String(format: "%.2f", sizeKB)) KB (\(String(format: "%.2f", sizeMB)) MB)")
        
        let filename = UUID().uuidString + ".heic"
        
        guard let documentsURL = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first else { return .failure(.folderNotFound) }
        
        let fileURL = documentsURL.appendingPathComponent(filename)
        
        do {
            try data.write(to: fileURL)
            return .success(filename)
            
        } catch {
            print("Error to save file: \(error.localizedDescription)")
            return .failure(.writeFailed(error.localizedDescription))
        }
    }
    
    static func loadImage(from filename: String) -> UIImage? {
        guard !filename.isEmpty else { return nil }
        
        let paths = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )
        let fileURL = paths[0].appendingPathComponent(filename)
        
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return nil
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            return UIImage(data: data)
        } catch {
            print("Error to load image: \(error)")
            return nil
        }
    }
    
    static func deleteImage(filename: String?) {
        guard let filename = filename, !filename.isEmpty else { return }
        
        guard let documentsURL = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first else { return }
        
        let fileURL = documentsURL.appendingPathComponent(filename)
        
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try FileManager.default.removeItem(at: fileURL)
                print("Delete image: \(filename)")
                
            } catch {
                print("Error to delete image: \(error)")
            }
        }
    }
}
