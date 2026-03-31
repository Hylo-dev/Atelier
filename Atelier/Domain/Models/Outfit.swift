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
        
        // Date variables
        var creationDate     : Date    // Implemented in InfView
        var lastWornDate     : Date?   // Implemented in InfView
        
        // Info variables
        var wearCount        : Int     // Implemented in InfView
        var fullLookImagePath: String? // Implemented yet
        var isFavorite       : Bool    // Implemented in InfView
        var notes            : String? // Implemented in InfView
        
        // Style variables
        var season           : Season
        var occasion         : [GarmentStyle] // Implemented in InfView
        
        
        var colors: [ColorWeight] {
            guard !garments.isEmpty else { return [] }
            
            return ColorWeight.from(
                garments.map { $0.color }
            )
            .sorted { $0.weight >= $1.weight && $0.id >= $1.id }
        }
        
        @MainActor
        var totalValue: Double {
            garments.reduce(0) { $0 + ($1.price ?? 0) }
        } // Implemented in InfView
        
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
            isReadyToWear ? "Ready" : "Incomplete"
        }
        
        @MainActor
        var missingItemsCount: Int {
            garments.filter { $0.state != .available }.count
        }
        
        init(
            name             : String,
            garments         : [Garment],
            season           : Season,
            fullLookImagePath: String?,
            isFavorite       : Bool    = false,
            notes            : String? = nil,
            occasion         : [GarmentStyle]
        ) {
            self.id                = UUID()
            self.name              = name
            self.garments          = garments
            
            self.season            = season
            
            self.creationDate      = .now
            self.lastWornDate      = nil
            
            self.wearCount         = 0
            self.fullLookImagePath = fullLookImagePath
            self.isFavorite        = isFavorite
            self.notes             = notes
            
            self.occasion          = occasion
        }
        
        init() {
            self.id                = UUID()
            self.name              = ""
            self.garments          = []
            self.season            = .summer
            self.occasion          = [.casual]
            self.creationDate      = .now
            self.lastWornDate      = nil
            self.wearCount         = 0
            self.isFavorite        = false
            self.notes             = nil
            self.fullLookImagePath = nil
        }
    }
}
