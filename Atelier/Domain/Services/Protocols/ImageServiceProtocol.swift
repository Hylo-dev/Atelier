//
//  ImageServiceProtocol.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 07/04/2026.
//

import UIKit


protocol ImageServiceProtocol {
    func saveImage(
        _ image     : UIImage,
        maxDimension: CGFloat
    ) -> Result<String, ImageSaveError>
    
    func deleteImage(filename: String?)
}
