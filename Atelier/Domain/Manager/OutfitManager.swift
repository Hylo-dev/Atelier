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
    
    
    
    @MainActor
    func processOutfits(
        _ outfits: [Outfit],
        with filterManager: any FilterProtocol<Outfit>
    ) -> ProcessedOutfits {
        let filtered = filterManager.filter(outfits)
        
        var newGrouped: [String: [Outfit]] = ["All": filtered]
        
        let groupedBySeason = Dictionary(
            grouping: filtered,
            by      : { $0.season.title }
        )
        
        for (season, items) in groupedBySeason {
            newGrouped[season] = items
        }
        
        let uniqueSeasons = Set(outfits.lazy.map { $0.season.title })
        let newSeasons = ["All"] + uniqueSeasons.sorted()
        
        return ProcessedOutfits(
            visible: filtered,
            grouped: newGrouped,
            seasons: newSeasons
        )
    }
}
