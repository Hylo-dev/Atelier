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
        var config  = ImagePipeline.Configuration()
        
        let cache = ImageCache.shared
        cache.costLimit = 1024 * 1024 * 30
        cache.countLimit = 50
        
        let encoder = ImageEncoders.Default(compressionQuality: 0.60)
        
        config.makeImageEncoder = { _ in encoder }
        config.imageCache       = ImageCache.shared
        config.dataCache        = try? DataCache(name: "com.atelier.thumbnails")
        config.dataCachePolicy  = .storeEncodedImages
        
        return ImagePipeline(configuration: config)
    }()
    
    static let ephemeralPipeline: ImagePipeline = {
        var config = ImagePipeline.Configuration()
        
        let tinyCache = ImageCache()
        tinyCache.costLimit  = 1024 * 1024 * 15
        tinyCache.countLimit = 2
        
        config.imageCache = tinyCache        
        config.dataCache = nil
        
        return ImagePipeline(configuration: config)
    }()
}
