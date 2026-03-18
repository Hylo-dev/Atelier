//
//  ApplianceManager.swift
//  Atelier
//
//  Created by C4V4H.exe on 18/02/26.
//

import Observation
import SwiftData
import Foundation
import UserNotifications

@MainActor
@Observable
final class ApplianceManager: Manager {
    var context: ModelContext
    
    
    init(_ context: ModelContext) {
        self.context = context
    }
    
    
    
    // MARK: - Database CRUD handler
    
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
    
    
    
    @inline(__always)
    internal func save() {
        do {
            try context.save()
            
        } catch {
            print("Error DB: \(error)")
        }
    }
    
    
    
    // MARK: Garment handlers
    
    func unassignGarment(_ garment: Garment) {
        
        if let session = garment.activeLaundrySession {
            
            garment.laundryHistory.removeAll(where: { $0.id == session.id })
            
            garment.isBinAssigned = false
            garment.state         = .available
            
            if session.garments.isEmpty {
                context.delete(session)
                
            } else {
                session.updateWarnings()
            }
            save()
        }
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
                
                if !garment.laundryHistory.contains(exactSession) {
                    garment.laundryHistory.append(exactSession)
                }
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
                
                context.insert(newSession)
                
                garment.laundryHistory.append(newSession)
                newSession.updateWarnings()
                activeSessions.append(newSession)
            }
            
            garment.isBinAssigned = true
            garment.state = .toWash
        }
        
        save()
    }
    
    
    
    // MARK: - Laundry Session live
    
    
    
    // MARK: - Wash
    
    func startWashing(_ session: LaundrySession) {
        session.status           = .washing
        session.startDate        = .now
        
        // TODO: - Remember remove the "-99" because this is for testing
        let minutes = session.suggestedProgram.washingTime - 99
        let targetDate = Calendar.current.date(byAdding: .minute, value: minutes, to: .now) ?? .now
        session.completationDate = targetDate
        
        for garment in session.garments {
            garment.state = .washing
        }
        
        LaundryActivityManager.shared.start(
            programName: session.suggestedProgram.displayName,
            startDate  : session.startDate ?? .now,
            targetDate : targetDate,
            sessionId  : session.id.uuidString,
            temperature: session.targetTemperature
        )
        
        save()
    }
    
    
    func resumeWashing(_ session: LaundrySession) {
        guard let targetDate = session.completationDate,
              let startDate  = session.startDate else { return }
        
        
        if targetDate.timeIntervalSinceNow > 10 {
            LaundryActivityManager.shared.start(
                programName: session.suggestedProgram.displayName,
                startDate  : startDate,
                targetDate : targetDate,
                sessionId  : session.id.uuidString,
                temperature: session.targetTemperature
            )
            
        } else { finishWashing(session) }
        
        save()
    }
    
    
    
    func cancelWashing(_ session: LaundrySession) {
        session.status           = .planned
        session.startDate        = nil
        session.completationDate = nil
        
        for garment in session.garments {
            garment.state = .toWash
        }
        
        stopLiveActivity(session)
        save()
    }
    
    
    
    func finishWashing(_ session: LaundrySession) {
        session.status = .clean
        
        for garment in session.garments {
            garment.state = .drying
        }
        
        stopLiveActivity(session)
        save()
    }
    
    
    
    // MARK: Dry
    
    func startDrying(_ session: LaundrySession) {
        session.status = .drying
        save()
    }
    
    
    
    func cancelDrying(_ session: LaundrySession) {
        session.status = .clean
        save()
    }
    
    
    // TODO: Set logic for delete the session or save the history garments
    func markAsComplete(_ session: LaundrySession) {
        session.status = .completed
        
        for garment in session.garments {
            garment.state                = .available
            garment.isBinAssigned        = false
            garment.wearCount            = 0
            garment.lastWashingDate      = .now
        }
        
        save()
    }
    
    
    
    // MARK: Handlers
    
    func stopLiveActivity(_ session: LaundrySession) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [session.id.uuidString]
        )
        
        LaundryActivityManager.shared.stop()
    }
}
