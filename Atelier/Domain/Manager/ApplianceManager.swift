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
final class ApplianceManager {
    var context: ModelContext
    
    init(_ context: ModelContext) {
        self.context = context
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
    
    func processUnassignedGarments(
        _ garments       : [Garment],
        _ laundrySessions: [LaundrySession]
    ) {
        let unassignedGarments = garments.filter { !$0.isBinAssigned && $0.isReadyToWash }
        guard !unassignedGarments.isEmpty else { return }
        
        var activeSessions = laundrySessions
        for garment in unassignedGarments {
            
            if garment.washingSymbols.isEmpty && garment.composition.isEmpty {
                print("⚠️ Capo ignorato (\(garment.name)): mancano dati di lavaggio e composizione.")
                continue
            }
            
            // 1. MACRO-CESTO base (deciso dalla logica in Garment: A, B o C)
            let targetBin = garment.suggestedLaundryBin
            
            // 2. ESTRAIAMO IL PROFILO DEL SINGOLO CAPO
            // Temperatura massima tollerata dal capo
            let idealTemp = garment.washingSymbols
                .compactMap { $0.maxWashingTemperature }
                .min() ?? 40
            
            // Agitazione / Delicatezza
            let levels = garment.washingSymbols.map { $0.agitationLevel }
            var idealAgitation: WashingAgitation = .normal
            
            if levels.contains(.gentle) {
                idealAgitation = .gentle
                
            } else if levels.contains(.reduced) {
                idealAgitation = .reduced
            }
            
            let suggestedProgram: Program = idealAgitation.program
            
            // 3. SMISTAMENTO RIGIDO
            // Cerchiamo una sessione che abbia ESATTAMENTE gli stessi parametri
            if let exactSession = activeSessions.first(where: {
                $0.status == .planned &&
                $0.bin == targetBin &&
                $0.targetTemperature == idealTemp &&
                $0.suggestedProgram == suggestedProgram
            }) {
                // Il cesto perfetto esiste già, aggiungiamo il capo qui
                exactSession.garments.append(garment)
                exactSession.updateWarnings()
                
            } else {
                // Nessun cesto identico trovato? Creiamo un NUOVO cesto specializzato
                let newSession = LaundrySession(
                    bin: targetBin,
                    targetTemperature: idealTemp,
                    suggestedProgram: suggestedProgram,
                    garments: [garment]
                )
                
                newSession.updateWarnings()
                activeSessions.append(newSession)
                
                context.insert(newSession)
            }
            
            // Segniamo il capo come processato
            garment.isBinAssigned = true
            garment.state         = .toWash
        }
        
        save()
    }
    
    @inline(__always)
    private func save() {
        do {
            try context.save()
            
        } catch {
            print("Error DB: \(error)")
        }
    }
}
