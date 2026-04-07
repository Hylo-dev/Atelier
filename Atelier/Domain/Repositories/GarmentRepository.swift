//
//  GarmentRepository.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 06/04/2026.
//

import Foundation
import UIKit

class GarmentRepository {
    private let imageService = ImageService()
    
    
    func create(
        garment : Garment,
        image   : UIImage?,
        manager : GarmentManager
    ) throws {
        
        if let imageToSave = image {
            
            let result = imageService.saveImage(imageToSave)
            
            switch result {
                case .success(let filename):
                    garment.imagePath = filename
                    
                case .failure(let error):
                    throw error
            }
        }
        
        try manager.insert(garment)
    }
    
    
    func update(
        garment : Garment,
        newImage: UIImage?,
        manager : GarmentManager
    ) throws {
        
        if let imageToSave = newImage {
            if let oldPath = garment.imagePath {
                imageService.deleteImage(filename: oldPath)
            }
            
            let result = imageService.saveImage(imageToSave)
            switch result {
                case .success(let filename):
                    garment.imagePath = filename
                    
                case .failure(let error):
                    throw error
            }
        }
        
        try manager.update()
    }
}
