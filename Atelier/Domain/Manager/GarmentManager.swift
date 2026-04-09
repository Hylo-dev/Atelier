//
//  GarmentManager.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 16/02/26.
//

import Observation
import SwiftData
import Foundation
import UIKit


@Observable
@MainActor
final class GarmentManager: Manager, GarmentWearLoggable, GarmentProcessing {
    private let context: ModelContext
    private let imageService: ImageServiceProtocol
    
    
    init(
        _ context: ModelContext,
        imageService: ImageServiceProtocol = ImageService()
    ) {
        self.context      = context
        self.imageService = imageService
    }
    
    
    
    @inline(__always)
    func insert(_ element: Garment) throws {
        context.insert(element)
        try context.save()
    }
    
    
    @inline(__always)
    func update() throws {
        try context.save()
    }
    
    @inline(__always)
    func delete(_ item: Garment) throws {
        if let image = item.imagePath, !image.isEmpty {
            imageService.deleteImage(filename: image)
        }
        
        if let session = item.activeLaundrySession {
            let remainingGarments = session.garments.filter {
                $0.id != item.id
            }
            
            let shouldCancelSession = !session.isCompleted && remainingGarments.allSatisfy { !$0.isBinAssigned }
            
            if shouldCancelSession {
                context.delete(session)
            }
        }
        
        context.delete(item)
        try context.save()
    }
    
    
    
    func logWear(
        for  item : Garment,
        each count: Int = 1
    ) -> Bool {
        item.wearCount += count
        
        if item.hasReachedWashingLimits {
            return true
        }
        
        return false
    }
    
    
    func setWashState(
        for  item   : Garment,
        used manager: ApplianceProcessing
    ) throws {
        item.forceWash = true
        
        try manager.processUnassignedGarments([item])
        try update()
    }
    
    
    func resetWear(
        for  item   : Garment,
        used manager: ApplianceProcessing
    ) throws {
        if let session = item.activeLaundrySession {
            try manager.detachGarment(item, from: session)
        }
        
        item.wearCount       = 0
        item.lastWashingDate = .now
        item.forceWash       = false
        item.isBinAssigned   = false
        item.state           = .available
        
        try update()
    }
    
    
    func process(_ garments: [Garment]) -> Processed<Garment> {
        var newGrouped: [String: [Garment]] = ["All": garments]
        
        let groupedByCategory = Dictionary(
            grouping: garments,
            by      : { $0.category.title }
        )
        
        for (category, items) in groupedByCategory {
            newGrouped[category] = items
        }
        
        let rawBrands    = Set(garments.compactMap { $0.brand })
        let sortedBrands = rawBrands.sorted()
        
        let uniqueCategories = Set(garments.lazy.map {
            $0.category.title
        })
        let newCategories    = ["All"] + uniqueCategories.sorted()
        
        return Processed(
            visible: garments,
            grouped: newGrouped,
            brands : sortedBrands,
            tag    : newCategories
        )
    }
}
