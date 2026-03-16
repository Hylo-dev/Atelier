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
        
        var dateCreated     : Date
        var startDate       : Date?
        var completationDate: Date?
        var status          : LaundrySessionStatus
        
        @Relationship
        var garments: [Garment]
        
        var bin: LaundryBin
        var targetTemperature: Int
        var suggestedProgram: Program
        
        var laundrySymbols: Set<LaundrySymbol>
        
        var warnings: [LaundryWarning]
        
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
            var newWarnings: Set<LaundryWarning> = []
            
            if garments.contains(where: { $0.category == .lingerie }) {
                newWarnings.insert(.meshBagRequired)
            }
            
            if garments.contains(
                where: {
                    let maxTemp = $0.washingSymbols.compactMap {
                        $0.maxWashingTemperature
                    }.min() ?? 40
                    
                    return self.targetTemperature > maxTemp
                }
            ) {
                newWarnings.insert(.temperatureTooHigh)
            }
            
            let sessionColor = self.bin.colorGroup
            if sessionColor == .whites || sessionColor == .pastels {
                
                let hasDarkItems = garments.contains {
                    let itemColorGroup = WashingColorGroup.classify($0.color)
                    return itemColorGroup == .darks || itemColorGroup == .vibrant
                }
                
                if hasDarkItems {
                    newWarnings.insert(.colorBleedingRisk)
                }
            }
            
            if suggestedProgram != .handWash && garments.contains(where: { $0.washingSymbols.contains(.handWash) }) {
                newWarnings.insert(.handWashOnly)
            }
            
            self.warnings = Array(newWarnings)
        }
    }
}
