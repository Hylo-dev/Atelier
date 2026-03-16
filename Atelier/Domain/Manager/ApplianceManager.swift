//
//  ApplianceManager.swift
//  Atelier
//
//  Created by C4V4H.exe on 18/02/26.
//

import Observation
import SwiftData
import Foundation

@MainActor
@Observable
final class ApplianceManager: Manager {
    var context: ModelContext

    
    
    init(_ context: ModelContext) {
        self.context = context
    }
    
    
    
    func insert(_ element: LaundrySession) {
        context.insert(element)
        save()
    }
    
    
    
    func update() {
        save()
    }
    
    
    
    func delete(_ element: LaundrySession) {
        context.delete(element)
        save()
    }
    
    
    
    func unassignGarment(_ garment: Garment) {
        
        if let oldSession = garment.activeLaundrySession {
            
            garment.activeLaundrySession = nil
            garment.isBinAssigned        = false
            
            if oldSession.garments.isEmpty {
                context.delete(oldSession)
                
            } else {
                oldSession.updateWarnings()
            }
            
            save()
        }
    }
    
    
    
    func startWashing(_ session: LaundrySession) {
        session.status           = .washing
        session.startDate        = .now
        
        let minutes = session.suggestedProgram.washingTime
        session.completationDate = Calendar.current.date(
            byAdding: .minute,
            value   : minutes,
            to      : .now
        )
        
        for garment in session.garments {
            garment.state = .washing
        }
        
        save()
    }
    
    
    
    func finishWashing(_ session: LaundrySession) {
        session.status = .completed
        
        for garment in session.garments {
            garment.state = .drying
        }
        
        save()
    }
    
    
    
    func startDrying(_ session: LaundrySession) {
        session.status = .drying
        save()
    }
    
    
    
    func markAsClean(_ session: LaundrySession) {
        session.status = .clean
        
        for garment in session.garments {
            garment.state                = .available
            garment.isBinAssigned        = false
            garment.activeLaundrySession = nil
            garment.wearCount            = 0
            garment.lastWashingDate      = .now
        }
        
        save()
    }
    
    
    
    func processUnassignedGarments(
        _ garments: [Garment],
        _ laundrySessions: [LaundrySession]
    ) {
        
        let unassignedGarments = garments.filter {
            !$0.isBinAssigned && $0.isReadyToWash
        }
        guard !unassignedGarments.isEmpty else { return }
        
        var activeSessions = laundrySessions
        let engine = LaundryEngine()
        
        for garment in unassignedGarments {
            
            if garment.washingSymbols.isEmpty && garment.composition.isEmpty {
                print("⚠️ Capo ignorato (\(garment.name)): mancano dati di lavaggio e composizione.")
                continue
            }
            
            let decision = engine.process(garment)
            
            if let exactSession = activeSessions.first(where: {
                $0.status == .planned &&
                $0.bin == decision.bin &&
                $0.suggestedProgram == decision.suggestedProgram
            }) {
                let garmentMaxTemp = garment.washingSymbols.compactMap {
                    $0.maxWashingTemperature
                }.min() ?? 40
                
                exactSession.targetTemperature = min(
                    exactSession.targetTemperature,
                    garmentMaxTemp
                )
                
                exactSession.garments.append(garment)
                exactSession.laundrySymbols.formUnion(garment.washingSymbols)
                exactSession.updateWarnings()
                
            } else {
                let newSession = LaundrySession(
                    bin              : decision.bin,
                    targetTemperature: decision.targetTemperature,
                    suggestedProgram : decision.suggestedProgram,
                    garments         : [garment],
                    laundrySymbols   : Set(garment.washingSymbols)
                )
                
                newSession.updateWarnings()
                activeSessions.append(newSession)
                context.insert(newSession)
            }
            
            garment.isBinAssigned = true
            garment.state = .toWash
        }
        
        save()
    }
    
    
    @inline(__always)
    internal func save() {
        do {
            try context.save()
            
        } catch {
            print("Error DB: \(error)")
        }
    }
}
