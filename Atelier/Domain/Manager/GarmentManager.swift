//
//  GarmentManager.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 16/02/26.
//

import Observation
import SwiftData
import Foundation

@Observable
@MainActor
final class GarmentManager: Manager {
    var context: ModelContext
    
    var visibleGarments: [Garment]           = []
    var groupedGarments: [String: [Garment]] = [:]
    var availableBrands: [String]            = []
    var availableCategories: [String]        = []
    
    
    
    init(_ context: ModelContext) {
        self.context = context
    }
    
    
    
    @inline(__always)
    func insert(_ element: Garment) {
        context.insert(element)
        save()
    }
    
    
    
    @inline(__always)
    func update() {
        save()
    }
    
    @inline(__always)
    func delete(_ item: Garment) {
        ImageStorage.deleteImage(filename: item.imagePath)
        
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
    
    
    
    func logWear(
        for  item    : Garment,
        in   sessions: [LaundrySession],
        used manager : ApplianceManager,
        each count   : Int = 1
    ) {
        item.wearCount += count
        
        if item.hasReachedWashingLimits {
            manager.processUnassignedGarments(
                [item],
                sessions
            )
        }
        
        self.update()
    }
    
    
    func setWashState(
        for  item    : Garment,
        in   sessions: [LaundrySession],
        used manager : ApplianceManager
    ) {
        item.forceWash = true
        
        manager.processUnassignedGarments(
            [item],
            sessions
        )
        
        self.update()
    }
    
    
    
    func resetWear(
        for  item: Garment,
        used manager: ApplianceManager
    ) {
        item.wearCount       = 0
        item.lastWashingDate = .now
        item.forceWash       = false
        item.isBinAssigned   = false
        item.state           = .available
        
        
        if let session = item.activeLaundrySession,
           session.isCancel {
            
            manager.delete(session)
        }
        
        
        self.update()
    }
    
    
    
    @MainActor
    func processGarments(_ garments: [Garment], with filter: FilterGarmentConfig) {
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
        
        
        
        self.visibleGarments = filtered
        self.groupedGarments = newGrouped
        
        if self.availableBrands != sortedBrands {
            self.availableBrands = sortedBrands
        }
        
        if self.availableCategories != newCategories {
            self.availableCategories = newCategories
        }
    }
}
