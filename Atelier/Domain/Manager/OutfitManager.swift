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
    var context: ModelContext
    
    var visibleOutfits  : [Outfit]           = []
    var groupedOutfits  : [String: [Outfit]] = [:]
    var availableSeasons: [String]           = []
    
    init(_ context: ModelContext) {
        self.context = context
    }
    
    @inline(__always)
    func insert(_ element: Outfit) {
        context.insert(element)
        save()
    }
    
    @inline(__always)
    func update() {
        save()
    }
    
    @inline(__always)
    func delete(_ element: Outfit) {
        self.context.delete(element)
        save()
    }
    
    @inline(__always)
    internal func save() {
        do {
            try context.save()
        } catch {
            print("Error DB: \(error)")
        }
    }
    
    
    
    func logOutfitWear(
        for outfit      : Outfit,
        garmentManager  : GarmentManager,
        in sessions     : [LaundrySession],
        applianceManager: ApplianceManager,
        each count      : Int = 1
    ) {
        outfit.wearCount    += count
        outfit.lastWornDate  = .now
        
        for garment in outfit.garments {
            garmentManager.logWear(
                for : garment,
                used: applianceManager
            )
        }
        
        self.update()
    }
    
    
    
    func moveOutfitToWash(
        for outfit: Outfit,
        garmentManager: GarmentManager,
        in sessions: [LaundrySession],
        applianceManager: ApplianceManager
    ) {
        for garment in outfit.garments {
            garmentManager.logWear(
                for : garment,
                used: applianceManager,
                each: 20
            )
        }
        
        garmentManager.update()
    }
    
    
    
    func toggleOutfitLoan(
        _ outfit      : Outfit,
        garmentManager: GarmentManager
    ) {
        let newState: GarmentState = outfit.isOnLoan ? .available : .onLoan
        
        for garment in outfit.garments {
            garment.state = newState
            
            if newState == .onLoan {
                //garmentManager.resetWear(for: garment)
            }
        }
        
        garmentManager.update()
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
