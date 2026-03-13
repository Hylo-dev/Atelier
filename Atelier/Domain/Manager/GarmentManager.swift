//
//  GarmentManager.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 16/02/26.
//

import Observation
import SwiftData

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
    func delete(_ garment: Garment) {
        ImageStorage.deleteImage(filename: garment.imagePath)
        self.context.delete(garment)
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
