//
//  GarmentRepository.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 06/04/2026.
//

import Foundation
import UIKit

struct GarmentRepository: RepositoryProtocol {
    typealias T = Garment
    typealias M = any GarmentManaging
    
    private let imageService: ImageServiceProtocol
    
    init(imageService: ImageServiceProtocol = ImageService()) {
        self.imageService = imageService
    }
    
    func create(
        item    : Garment,
        image   : UIImage?,
        manager : any GarmentManaging
    ) throws {
        if let imageToSave = image {
            let result = imageService.saveImage(imageToSave, maxDimension: 1024)
            switch result {
                case .success(let filename): item.imagePath = filename
                case .failure(let error): throw error
            }
        }
        try manager.insert(item)
    }
    
    func update(
        item    : Garment,
        image   : UIImage?,
        manager : any GarmentManaging
    ) throws {
        if let imageToSave = image {
            if let oldPath = item.imagePath {
                imageService.deleteImage(filename: oldPath)
            }
            let result = imageService.saveImage(imageToSave, maxDimension: 1024)
            switch result {
                case .success(let filename): item.imagePath = filename
                case .failure(let error): throw error
            }
        }
        try manager.update()
    }
}
