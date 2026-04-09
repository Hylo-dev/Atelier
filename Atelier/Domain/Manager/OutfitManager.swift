//
//  OutfitManager.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 17/02/26.
//

import Observation
import SwiftData
import Foundation


@Observable
@MainActor
final class OutfitManager: Manager {
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
    func insert(_ element: Outfit) throws {
        context.insert(element)
        try context.save()
    }
    
    @inline(__always)
    func update() throws {
        try context.save()
    }
    
    @inline(__always)
    func delete(_ element: Outfit) throws {
        if let image = element.fullLookImagePath, !image.isEmpty {
            imageService.deleteImage(filename: image)
        }
        
        context.delete(element)
        try context.save()
    }
    
    
    func logOutfitWear(
        for outfit    : Outfit,
        garmentManager: any GarmentWearLoggable,
        processGarment: ApplianceProcessing,
        each count    : Int = 1
    ) throws {
        outfit.wearCount    += count
        outfit.lastWornDate  = .now
        
        let garmentsToWash = outfit.garments.filter { garment in
            garmentManager.logWear(for: garment, each: 1)
        }
        
        if !garmentsToWash.isEmpty {
            try processGarment.processUnassignedGarments(garmentsToWash)
        }
        
        try update()
    }
    
    
    
    func moveOutfitToWash(
        for outfit    : Outfit,
        garmentManager: any GarmentWearLoggable,
        processGarment: ApplianceProcessing
    ) throws {
        let garmentsToWash = outfit.garments.filter { garment in
            garmentManager.logWear(for: garment, each: 20)
        }
        
        if !garmentsToWash.isEmpty {
            try processGarment.processUnassignedGarments(garmentsToWash)
        }
        
        try update()
    }
    
    
    
    func toggleOutfitLoan(_ outfit: Outfit) throws {
        let newState: GarmentState = outfit.isOnLoan ? .available : .onLoan
        
        for garment in outfit.garments {
            garment.state = newState
            
            if newState == .onLoan {
                //garmentManager.resetWear(for: garment)
            }
        }
        
        try update()
    }
    
        
    func process(_ outfits: [Outfit]) async -> Processed<Outfit> {
        
        let dtos = outfits.map { outfit in
            OutfitDTO(
                id         : outfit.persistentModelID,
                secondLabel: outfit.season.title
            )
        }
        
        let actor = GroupActor()
        let result = await actor.computeGroups(from: dtos)
        
        let outfitDict = Dictionary(
            uniqueKeysWithValues: outfits.map { ($0.persistentModelID, $0) }
        )
        
        var finalGrouped: [String: [Outfit]] = [:]
        
        for (category, ids) in result.groupedIDs {
            finalGrouped[category] = ids.compactMap { outfitDict[$0] }
        }
        
        finalGrouped["All"] = outfits
        return Processed(
            grouped: finalGrouped,
            brands : result.brands,
            tag    : result.tags
        )
    }
}
