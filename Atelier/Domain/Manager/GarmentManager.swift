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
final class GarmentManager: Manager {
    private let context: ModelContext
    
    var visibleGarments: [Garment]           = []
    var groupedGarments: [String: [Garment]] = [:]
    var availableBrands: [String]            = []
    var availableCategories: [String]        = []
    
    
    
    init(_ context: ModelContext) {
        self.context = context
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
        ImageService().deleteImage(filename: item.imagePath)
        
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
        for  item   : Garment,
        used manager: ApplianceManager,
        each count  : Int = 1
    ) throws {
        item.wearCount += count
        
        if item.hasReachedWashingLimits {
            try manager.processUnassignedGarments([item])
        }
        
        try update()
    }
    
    
    func setWashState(
        for  item   : Garment,
        used manager: ApplianceManager
    ) throws {
        item.forceWash = true
        
        try manager.processUnassignedGarments([item])
        try update()
    }
    
    
    
    func resetWear(
        for  item: Garment,
        used manager: ApplianceManager
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
    
    
    
    func processGarments(
        _ garments: [Garment],
        with filter: FilterGarmentConfig
    ) {
        let filtered = FilterGarmentConfig.filterGarments(
            allGarments: garments,
            config     : filter
        )
        
        var newGrouped: [String: [Garment]] = ["All": filtered]
        
        let groupedByCategory = Dictionary(
            grouping: filtered,
            by      : { $0.category.title }
        )
        
        for (category, items) in groupedByCategory {
            newGrouped[category] = items
        }
        
        let rawBrands    = Set(garments.compactMap { $0.brand })
        let sortedBrands = rawBrands.sorted()
        
        let uniqueCategories = Set(garments.lazy.map { $0.category.title })
        let newCategories    = ["All"] + uniqueCategories.sorted()
        
        let newVisibleIDs  = filtered.map(\.id)
        let currVisibleIDs = visibleGarments.map(\.id)
        
        if newVisibleIDs != currVisibleIDs {
            self.visibleGarments = filtered
        }
        
//        let newGroupedIDs  = newGrouped.mapValues { $0.map(\.id) }
//        let currGroupedIDs = groupedGarments.mapValues { $0.map(\.id) }
        
//        if newGroupedIDs != currGroupedIDs {
//            self.groupedGarments = newGrouped
//        }
        
        self.groupedGarments = newGrouped
        
        if self.availableBrands != sortedBrands {
            self.availableBrands = sortedBrands
        }
        
        if self.availableCategories != newCategories {
            self.availableCategories = newCategories
        }
    }
}


//struct ProcessedGarmentResult: Sendable {
//    let visibleIDs: [PersistentIdentifier]
//    let groupedIDs: [String: [PersistentIdentifier]]
//    let availableBrands: [String]
//    let availableCategories: [String]
//}
//
//@ModelActor
//actor GarmentProcessingActor {
//    
//    func process(
//        garmentIDs: [PersistentIdentifier],
//        with config: FilterGarmentConfig
//    ) -> ProcessedGarmentResult {
//        
//        // 1. Risolviamo i PersistentIdentifier nel ModelContext di background
//        var backgroundGarments: [Garment] = []
//        for id in garmentIDs {
//            // Usiamo model(for:) per assicurarci di recuperarlo dal DB
//            if let garment = self.modelContext.model(for: id) as? Garment {
//                backgroundGarments.append(garment)
//            }
//        }
//        
//        // 2. Applichiamo il filtro (esattamente la tua logica)
//        let filtered = FilterGarmentConfig.filterGarments(
//            allGarments: backgroundGarments,
//            config: config
//        )
//        
//        // 3. Estraiamo gli ID dei capi visibili
//        let visibleIDs = filtered.map { $0.persistentModelID }
//        
//        // 4. Creiamo il dizionario raggruppato mappato in PersistentIdentifier
//        var groupedIDs: [String: [PersistentIdentifier]] = ["All": visibleIDs]
//        
//        let groupedByCategory = Dictionary(
//            grouping: filtered,
//            by      : { $0.category.title }
//        )
//        
//        for (category, items) in groupedByCategory {
//            groupedIDs[category] = items.map { $0.persistentModelID }
//        }
//        
//        // 5. Calcoliamo i set per brand e categorie
//        let rawBrands    = Set(backgroundGarments.compactMap { $0.brand })
//        let sortedBrands = rawBrands.sorted()
//        
//        let uniqueCategories = Set(backgroundGarments.lazy.map { $0.category.title })
//        let newCategories    = ["All"] + uniqueCategories.sorted()
//        
//        // 6. Ritorniamo il DTO Sendable
//        return ProcessedGarmentResult(
//            visibleIDs: visibleIDs,
//            groupedIDs: groupedIDs,
//            availableBrands: sortedBrands,
//            availableCategories: newCategories
//        )
//    }
//}
