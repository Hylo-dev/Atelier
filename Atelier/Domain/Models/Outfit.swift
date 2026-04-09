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
        var creationDate     : Date
        var lastWornDate     : Date?
        
        // Info variables
        var wearCount        : Int
        var fullLookImagePath: String?
        var isFavorite       : Bool
        var notes            : String?
        
        // Style variables
        
        var seasonRaw: String
        var season: Season {
            get { Season(rawValue: seasonRaw) ?? .summer }
            set { seasonRaw = newValue.rawValue }
        }
        
        
        var occasionsRaw: [String]
        var occasion: [GarmentStyle] {
            get {
                occasionsRaw.map { GarmentStyle(rawValue: $0) ?? .casual }
            }
            
            set {
                occasionsRaw = newValue.map { $0.rawValue }
            }
        }
        
        
        var totalValue: Double
        
        
        var colors: [ColorWeight] {
            guard !garments.isEmpty else { return [] }
            
            return ColorWeight.from(
                garments.map { $0.color }
            )
            .sorted { $0.weight >= $1.weight && $0.id >= $1.id }
        }
        
        var isReadyToWearRaw: Bool
        @MainActor
        var isReadyToWear: Bool {
            get {
                guard !garments.isEmpty else { return false }
                
                let result = garments.allSatisfy { $0.state == .available }
                isReadyToWearRaw = result
                
                return result
            }
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
        
        // TODO: Potential bug, because the tone is a computed varible
        var toneRaw: String
        @MainActor
        var tone: Tone {
            get {
                guard !garments.isEmpty else { return .none }
                
                var temperatureValue = 0.0
                var garmentsWeight = 0.0
                
                garments.forEach { garment in
                    let color  = Color(hex: garment.color)
                    let weight = garment.subCategory.weight
                    
                    garmentsWeight   += weight
                    temperatureValue += weight * color.temperatureValue
                }
                
                let tone = Tone(score: temperatureValue / garmentsWeight)
                
                toneRaw = tone.rawValue
                return tone
            }
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
            
            self.seasonRaw         = season.rawValue
            
            self.creationDate      = .now
            self.lastWornDate      = nil
            
            self.wearCount         = 0
            self.fullLookImagePath = fullLookImagePath
            self.isFavorite        = isFavorite
            self.notes             = notes
            
            self.occasionsRaw      = occasion.map { $0.rawValue }
            
            self.totalValue        = garments.reduce(0) { $0 + ($1.price ?? 0) }
            self.toneRaw           = ""
            self.isReadyToWearRaw  = true
        }

//
//        init() {
//            self.id                = UUID()
//            self.name              = ""
//            self.garments          = []
//            self.season            = .summer
//            self.occasion          = [.casual]
//            self.creationDate      = .now
//            self.lastWornDate      = nil
//            self.wearCount         = 0
//            self.isFavorite        = false
//            self.notes             = nil
//            self.fullLookImagePath = nil
//        }
//        
    }
}
