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
    
    var name : String
    var brand: String?
    var color: String
    var type : GarmentType
    
    var washingSymbols : [WashingSymbol]
    var lastWashingDate: Date?
    var purchaseDate   : Date
    var wearCount      : Int
    
    var imagePath  : String? // Path to image 2D
    var model3DPath: String? // Path to model 3D
    
    init(
        id            : UUID = UUID(),
        name          : String,
        brand         : String? = nil,
        color         : String,
        type          : GarmentType,
        washingSymbols: [WashingSymbol] = [],
        purchaseDate  : Date = .now
    ) {
        self.id             = id
        self.name           = name
        self.brand          = brand
        self.color          = color
        self.type           = type
        self.washingSymbols = washingSymbols
        self.purchaseDate   = purchaseDate
        self.wearCount      = 0
    }
}
