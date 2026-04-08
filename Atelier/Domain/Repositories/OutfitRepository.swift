//
//  OutfitRepository.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 06/04/2026.
//

import UIKit

struct OutfitRepository: RepositoryProtocol {
    typealias T = Outfit
    typealias M = Manager<Outfit>
    
    private let imageService: ImageServiceProtocol
    
    init(imageService: ImageServiceProtocol = ImageService()) {
        self.imageService = imageService
    }
    
    func create(
        item   : Outfit,
        image  : UIImage?,
        manager: any Manager<Outfit>
    ) throws {
        
        if let imageToSave = image {
            let result = imageService.saveImage(
                imageToSave,
                maxDimension: 1024
            )
            
            switch result {
                case .success(let filename):
                    item.fullLookImagePath = (filename as NSString).lastPathComponent
                    
                case .failure(let error):
                    throw error
            }
        }
        
        try manager.insert(item)
    }
    
    func update(
        item   : Outfit,
        image  : UIImage?,
        manager: any Manager<Outfit>
    ) throws {
        if let imageToSave = image {
            if let oldPath = item.fullLookImagePath {
                imageService.deleteImage(filename: oldPath)
            }
            
            switch imageService.saveImage(
                imageToSave,
                maxDimension: 1024
            ) {
                case .success(let filename):
                    item.fullLookImagePath = (filename as NSString).lastPathComponent
                    
                case .failure(let error):
                    throw error
            }
        }
        
        try manager.update()
    }
}
