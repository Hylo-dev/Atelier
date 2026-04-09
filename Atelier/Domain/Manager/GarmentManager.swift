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
    
    
    func process(_ garments: [Garment]) async -> Processed<Garment> {
        let dtos = garments.map { garment in
            GarmentDTO(
                id           : garment.persistentModelID,
                firstLabel   : garment.brand,
                secondLabel  : garment.category.title
            )
        }
        
        let actor = GroupActor()
        let result = await actor.computeGroups(from: dtos)
        
        var finalGrouped: [String: [Garment]] = [:]
        
        for (category, ids) in result.groupedIDs {
            finalGrouped[category] = garments.filter {
                ids.contains($0.persistentModelID)
            }
        }
        
        finalGrouped["All"] = garments
        return Processed(
            grouped: finalGrouped,
            brands : result.brands,
            tag    : result.tags
        )
    }
}
