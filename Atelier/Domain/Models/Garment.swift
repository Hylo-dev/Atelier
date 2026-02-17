//
//  Garmen.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 15/02/26.
//

import SwiftData
import Foundation

@Model
final class Garment {
    @Attribute(.unique) var id: UUID
    
    // MARK: - Object Description
    var name        : String
    var brand       : String?
    var color       : String
    var composition : [GarmentComposition]
    var category    : GarmentCategory
    var subCategory : GarmentSubCategory
    var season      : Season
    var style       : GarmentStyle
    var purchaseDate: Date
    var state       : GarmentState

    
    // MARK: - Washing Info
    var washingSymbols : [LaundrySymbol]
    var lastWashingDate: Date?
    var wearCount      : Int
    
        
    // MARK: - Graphic
    var imagePath  : String? // Path to image 2D
    var model3DPath: String? // Path to model 3D
    
    
    init(
        id            : UUID = UUID(),
        name          : String,
        brand         : String? = nil,
        color         : String,
        composition   : [GarmentComposition],
        category      : GarmentCategory,
        subCategory   : GarmentSubCategory,
        season        : Season,
        style         : GarmentStyle,
        purchaseDate  : Date = .now,
        washingSymbols: [LaundrySymbol] = [],
        imagePath     : String? = nil,
        model3DPath   : String? = nil
    ) {
        self.id             = id
        self.name           = name
        self.brand          = brand
        self.color          = color
        self.composition    = composition
        self.category       = category
        self.subCategory    = subCategory
        self.season         = season
        self.style          = style
        self.purchaseDate   = purchaseDate
        self.state          = .available
        
        self.washingSymbols = washingSymbols
        self.wearCount      = 0
        
        self.imagePath      = imagePath
        self.model3DPath    = model3DPath
    }
}
