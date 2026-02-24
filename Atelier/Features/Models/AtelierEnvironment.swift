//
//  AtelierEnvironment.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 24/02/26.
//


import Foundation
import Nuke

enum AtelierEnvironment {
    static let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    
    static let imagePipeline: ImagePipeline = {
        var config = ImagePipeline.Configuration()
        config.imageCache = ImageCache.shared
        config.dataCache = try? DataCache(name: "com.atelier.thumbnails")
        config.dataCachePolicy = .storeEncodedImages
        return ImagePipeline(configuration: config)
    }()
}
