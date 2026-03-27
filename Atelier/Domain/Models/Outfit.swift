//
//  Outfit.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 17/02/26.
//

import SwiftUI
import SwiftData

extension AtelierSchemaV1 {
    
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
        
        @MainActor
        var isReadyToWear: Bool {
            guard !garments.isEmpty else { return false }
            
            return garments.allSatisfy { $0.state == .available }
        }
        
        @MainActor
        var isOnLoan: Bool {
            garments.contains { $0.state == .onLoan }
        }
        
        @MainActor
        var stateWear: String {
            isReadyToWear ? "Yes" : "No"
        }
        
        @MainActor
        var missingItemsCount: Int {
            garments.filter { $0.state != .available }.count
        }
        
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
        
        init() {
            self.id                = UUID()
            self.name              = ""
            self.garments          = []
            self.season            = .summer
            self.style             = .casual
            self.lastWornDate      = nil
            self.wearCount         = 0
            self.fullLookImagePath = nil
        }
    }
}
