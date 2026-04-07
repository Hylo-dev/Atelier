//
//  LaundryAssignmentManaging.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 07/04/2026.
//

import SwiftData
import Foundation


struct LaundryAssignmentService: LaundryAssignmentManaging {
    private let engine: LaundryEngineService
    
    init(engine: LaundryEngineService = LaundryEngine()) {
        self.engine = engine
    }

    func processUnassignedGarments(
        _ garments: [Garment],
        in context : ModelContext
        
    ) throws {
        let unassignedGarments = garments.filter {
            !$0.isBinAssigned && $0.isReadyToWash
        }
        
        guard !unassignedGarments.isEmpty else { return }
        
        let targetString = LaundrySessionStatus.planned.rawValue
        let descriptor = FetchDescriptor<LaundrySession>(
            predicate: #Predicate<LaundrySession> { session in
                session.statusRawValue == targetString
            }
        )
        var activeSessions = try context.fetch(descriptor)
        
        for garment in unassignedGarments {
            if garment.washingSymbols.isEmpty && garment.composition.isEmpty {
                print("⚠️ Capo ignorato (\(garment.name)): mancano dati di lavaggio e composizione.")
                continue
            }
            
            let decision = engine.process(garment)
            
            if let exactSession = activeSessions.first(where: {
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
                
                if !garment.laundryHistory.contains(exactSession) {
                    garment.laundryHistory.append(exactSession)
                }
                
                let existing = Set(exactSession.laundrySymbols)
                exactSession.laundrySymbols = Array(existing.union(garment.washingSymbols))
                exactSession.updateWarnings()
                
            } else {
                
                let newSession = LaundrySession(
                    bin              : decision.bin,
                    targetTemperature: decision.targetTemperature,
                    suggestedProgram : decision.suggestedProgram,
                    garments         : [garment],
                    laundrySymbols   : garment.washingSymbols
                )
                
                context.insert(newSession)
                
                garment.laundryHistory.append(newSession)
                newSession.updateWarnings()
                activeSessions.append(newSession)
            }
            
            garment.isBinAssigned = true
            garment.state = .toWash
        }
        
        try context.save()
    }
    
    
    func unassignGarment(
        _ garment: Garment,
        in context: ModelContext
        
    ) throws {
        guard let session = garment.activeLaundrySession,
              session.status == .planned else { return }
        
        session.garments.removeAll { $0.id == garment.id }
        garment.laundryHistory.removeAll { $0.id == session.id }
        
        garment.isBinAssigned = false
        garment.state         = .available
        
        if session.garments.isEmpty {
            context.delete(session)
        }
        
        try context.save()
    }
    
    func detachGarment(
        _    garment: Garment,
        from session: LaundrySession,
        in context  : ModelContext
    ) throws {
        session.garments.removeAll { $0.id == garment.id }
        
        if session.garments.isEmpty {
            context.delete(session)
        } else {
            session.updateWarnings()
        }
        
        try context.save()
    }
}
