//
//  Outfit.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 17/02/26.
//

import SwiftUI
import SwiftData

@Model
final class Outfit {
    @Attribute(.unique)
    var id: UUID
    
    var name: String
    
    @Relationship(deleteRule: .nullify)
    var garments: [Garment]
    
    var lastWornDate     : Date?
    var wearCount        : Int
    var fullLookImagePath: String?
    var season           : Season
    var style            : GarmentStyle
    
    var isReadyToWear: Bool {
        guard !self.garments.isEmpty else { return false }
        
        return self.garments.allSatisfy { $0.state == .available }
    }
    
    var stateWear: String {
        self.isReadyToWear ? "Yes" : "No"
    }
    
    var missingItemsCount: Int { self.garments.filter { $0.state != .available }.count }
    
    init(
        name    : String,
        garments: [Garment],
        season  : Season,
        fullLookImagePath: String?,
        style   : GarmentStyle
    ) {
        self.id                = UUID()
        self.name              = name
        self.garments          = garments
        self.season            = season
        self.style             = style
        self.lastWornDate      = nil
        self.wearCount         = 0
        self.fullLookImagePath = fullLookImagePath
    }
}
