//
//  LaundrySession.swift
//  Atelier
//
//  Created by C4V4H.exe on 18/02/26.
//
import SwiftData
import Foundation

extension AtelierSchemaV1 {
    
    
    
    @Model
    final class LaundrySession {
        @Attribute(.unique) var id: UUID
        
        var dateCreated: Date
        var status: LaundrySessionStatus
        
        @Relationship
        var garments: [Garment]
        
        var bin: LaundryBin
        var targetTemperature: Int
        var suggestedProgram: Program
        
        var laundrySymbols: Set<LaundrySymbol>
        
        var warnings: [String]
        
        init(
            bin              : LaundryBin,
            targetTemperature: Int,
            suggestedProgram : Program,
            garments         : [Garment] = [],
            laundrySymbols   : Set<LaundrySymbol>
        ) {
            self.id                = UUID()
            self.dateCreated       = .now
            self.status            = .planned
            self.bin               = bin
            self.garments          = garments
            self.warnings          = []
            
            self.targetTemperature = targetTemperature
            self.suggestedProgram  = suggestedProgram
            self.laundrySymbols    = laundrySymbols
        }
        
        func updateWarnings() {
            var newWarnings: [String] = []
            
            for garment in garments {
                
                if garment.subCategory.rawValue == "Bra" || garment.subCategory.rawValue == "Underwear" {
                    if !newWarnings.contains("Usa sacchetto a rete") {
                        newWarnings.append("Usa sacchetto a rete")
                    }
                }
            }
            
            self.warnings = newWarnings
        }
    }
}
