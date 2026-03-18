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
        @Attribute(.unique)
        var id: UUID
        
        var dateCreated     : Date
        var startDate       : Date?
        var completationDate: Date?
        var remainingTime   : TimeInterval?
        var status          : LaundrySessionStatus
        
        @Relationship
        var garments: [Garment]
        
        var bin: LaundryBin
        var targetTemperature: Int
        var suggestedProgram: Program
        
        var laundrySymbols: Set<LaundrySymbol>
        
        var warnings: [LaundryWarning]
        var isCompleted: Bool
        
        var isCancel: Bool {
            !isCompleted && garments.allSatisfy { !$0.isBinAssigned }
        }
        
        var subheadline: String? {
            switch self.status {
                case .planned:
                    return "\(self.garments.count) items • \(self.bin.displayName)"
                    
                case .washing:
                    return self.warnings.isEmpty ? "Washing..." : "⚠️ \(self.warnings.count) warnings"
                    
                case .paused:
                    return "Wash paused"
                    
                case .clean:
                    return "Clean • Ready to dry"
                    
                case .drying:
                    return "Drying..."
                    
                case .completed:
                    guard let completionDate = self.completationDate else { return "Completed" }
                    
                    let time = completionDate.formatted(date: .omitted, time: .shortened)
                    return if Calendar.current.isDateInToday(completionDate) {
                        "Finished at \(time)"
                        
                    } else if Calendar.current.isDateInYesterday(completionDate) {
                        "Finished yesterday at \(time)"
                        
                    } else {
                        "Finished on \(completionDate.formatted(.dateTime.month().day()))"
                    }
            }
        }
        
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
            self.isCompleted       = false
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
