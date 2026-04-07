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
    
    var visibleOutfits  : [Outfit]           = []
    var groupedOutfits  : [String: [Outfit]] = [:]
    var availableSeasons: [String]           = []
    
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
        for outfit      : Outfit,
        garmentManager  : GarmentManager,
        in sessions     : [LaundrySession],
        applianceManager: ApplianceManager,
        each count      : Int = 1
    ) throws {
        outfit.wearCount    += count
        outfit.lastWornDate  = .now
        
        for garment in outfit.garments {
            try garmentManager.logWear(
                for : garment,
                used: applianceManager
            )
        }
        
        try update()
    }
    
    
    
    func moveOutfitToWash(
        for outfit: Outfit,
        garmentManager: GarmentManager,
        in sessions: [LaundrySession],
        applianceManager: ApplianceManager
    ) throws {
        for garment in outfit.garments {
            try garmentManager.logWear(
                for : garment,
                used: applianceManager,
                each: 20
            )
        }
        
        try garmentManager.update()
    }
    
    
    
    func toggleOutfitLoan(
        _ outfit      : Outfit,
        garmentManager: GarmentManager
    ) throws {
        let newState: GarmentState = outfit.isOnLoan ? .available : .onLoan
        
        for garment in outfit.garments {
            garment.state = newState
            
            if newState == .onLoan {
                //garmentManager.resetWear(for: garment)
            }
        }
        
        try garmentManager.update()
    }
    
    
    
    @MainActor
    func processOutfits(_ outfits: [Outfit], with filter: FilterOutfitConfig) {
        let filtered = FilterOutfitConfig.filterOutfits(
            allOutfits: outfits,
            config    : filter
        )
        
        var newGrouped: [String: [Outfit]] = ["All": filtered]
        
        let groupedBySeason = Dictionary(
            grouping: filtered,
            by      : { $0.season.title }
        )
        
        for (season, items) in groupedBySeason {
            newGrouped[season] = items
        }
        
        let uniqueSeasons = Set(outfits.lazy.map { $0.season.title })
        let newSeasons    = ["All"] + uniqueSeasons.sorted()
        
        self.visibleOutfits   = filtered
        self.groupedOutfits   = newGrouped
        self.availableSeasons = newSeasons
    }
}
