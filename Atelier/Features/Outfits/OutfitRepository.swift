//
//  OutfitRepository.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 06/04/2026.
//

import UIKit

class OutfitRepository {
    private let imageService = ImageService()
    
    func create(
        outfit : Outfit,
        image  : UIImage?,
        manager: OutfitManager
    ) throws {
        
        if let imageToSave = image {
            let result = imageService.saveImage(imageToSave)
            
            switch result {
                case .success(let filename):
                    outfit.fullLookImagePath = (filename as NSString).lastPathComponent
                    
                case .failure(let error):
                    throw error
            }
        }
        
        manager.insert(outfit)
    }
    
    func update(
        outfit : Outfit,
        image  : UIImage?,
        manager: OutfitManager
    ) throws {
        if let imageToSave = image {
            if let oldPath = outfit.fullLookImagePath {
                imageService.deleteImage(filename: oldPath)
            }
            
            switch imageService.saveImage(imageToSave) {
                case .success(let filename):
                    outfit.fullLookImagePath = (filename as NSString).lastPathComponent
                    
                case .failure(let error):
                    throw error
            }
        }
        
        manager.update()
    }
}
