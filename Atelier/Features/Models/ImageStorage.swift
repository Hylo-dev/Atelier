//
//  ImageStorage.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 16/02/26.
//

import UIKit

struct ImageStorage {
    static func saveImage(_ image: UIImage) -> String? {
        
        guard let data = image.jpegData(compressionQuality: 0.8) else { return nil }
        
        let filename = UUID().uuidString + ".jpg"
        
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        let documentsDirectory = paths[0]
        let fileURL = documentsDirectory.appendingPathComponent(filename)
        
        do {
            try data.write(to: fileURL)
            return filename
            
        } catch {
            print("Error to save image: \(error)")
            return nil
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
}
