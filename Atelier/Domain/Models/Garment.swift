//
//  Garmen.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 15/02/26.
//

import SwiftData
import Foundation

// MARK: - Composition Struct

struct GarmentComposition: Identifiable, Codable {
    var id        : UUID = UUID()
    var fabric    : GarmentFabric
    var percentual: Double
}

// MARK: - Garment class

extension AtelierSchemaV1 {
    
    @Model
    final class Garment {
        @Attribute(.unique) var id: UUID
        
        // MARK: - Object Description
        var name        : String
        var brand       : String?
        var price       : Double?
        var color       : String
        var composition : [GarmentComposition]
        var category    : GarmentCategory
        var subCategory : GarmentSubCategory
        var season      : Season
        var style       : GarmentStyle
        var purchaseDate: Date
        var state       : GarmentState
        
        // MARK: Handler Washing
        var isBinAssigned: Bool
        var forceWash    : Bool
        
        
        // MARK: - Washing Info
        var washingSymbols : [LaundrySymbol]
        var lastWashingDate: Date?
        var wearCount      : Int
        
        
        // MARK: - UI Elements
        var imagePath  : String? // Path to image 2D
        var model3DPath: String? // Path to model 3D
        
        @Relationship(inverse: \AtelierSchemaV1.Outfit.garments)
        var outfits: [Outfit]
        
        @Relationship(inverse: \AtelierSchemaV1.LaundrySession.garments)
        var laundryHistory: [LaundrySession] = []
        
        var activeLaundrySession: LaundrySession? {
            laundryHistory.first {
                $0.status != .completed
            }
        }
        
        var isToWash: Bool {
            state == .toWash
        }
        
        init(
            id            : UUID = UUID(),
            name          : String,
            brand         : String? = nil,
            price         : Double? = nil,
            color         : String,
            composition   : [GarmentComposition],
            category      : GarmentCategory,
            subCategory   : GarmentSubCategory,
            season        : Season,
            style         : GarmentStyle,
            purchaseDate  : Date = .now,
            isBinAssigned : Bool = false,
            washingSymbols: [LaundrySymbol] = [],
            imagePath     : String? = nil,
            model3DPath   : String? = nil
        ) {
            self.id             = id
            self.name           = name
            self.brand          = brand
            self.price          = price
            self.color          = color
            self.composition    = composition
            self.category       = category
            self.subCategory    = subCategory
            self.season         = season
            self.style          = style
            self.purchaseDate   = purchaseDate
            
            self.isBinAssigned  = isBinAssigned
            self.forceWash      = false
            
            self.state          = .available
            
            self.washingSymbols = washingSymbols
            self.wearCount      = 0
            
            self.imagePath      = imagePath
            self.model3DPath    = model3DPath
            
            self.outfits        = []
            self.laundryHistory = []
        }


        @MainActor
        var requiresWashing: Bool {
            wearCount >= subCategory.wearLimit
        }
        
        @MainActor
        var daysSinceLastWash: Int {
            guard let lastWashingDate = lastWashingDate else { return 999 }
            return Calendar.current.dateComponents([.day], from: lastWashingDate, to: .now).day ?? 0
        }
        
        @MainActor
        var hasReachedWashingLimits: Bool {
            let wearLimitReached = wearCount >= subCategory.wearLimit
            let timeLimitReached = (daysSinceLastWash >= 30) && (wearCount > 0)
            
            return wearLimitReached || timeLimitReached
        }
        
        @MainActor
        var isReadyToWash: Bool {
            (state.readyToWash && hasReachedWashingLimits) || forceWash
        }
        
        @MainActor
        func totalPercentage(of category: FabricCategory) -> Double {
            composition
                .filter { $0.fabric.category == category }
                .reduce(0) { total, comp in total + comp.percentual }
        }
        
        @MainActor
        func totalPercentage(of fabrics: [GarmentFabric]) -> Double {
            composition
                .filter { fabrics.contains($0.fabric) }
                .reduce(0) { total, comp in total + comp.percentual }
        }
    }
}
