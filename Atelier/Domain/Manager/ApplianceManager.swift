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
    
    func detachGarment(_ garment: Garment, from session: LaundrySession) {
        session.garments.removeAll { $0.id == garment.id }
//        garment.laundryHistory.removeAll { $0.id == session.id }
        
        if session.garments.isEmpty {
            context.delete(session)
        } else {
            session.updateWarnings()
        }
        
        save()
    }
    
    func unassignGarment(_ garment: Garment) {
        guard let session = garment.activeLaundrySession,
              session.status == .planned else { return }
        
        session.garments.removeAll { $0.id == garment.id }
        garment.laundryHistory.removeAll { $0.id == session.id }
        
        garment.isBinAssigned = false
        garment.state         = .available
        
        if session.garments.isEmpty {
            context.delete(session)
        } else {
            session.updateWarnings()
        }
        
        save()
    }
    
    
    
    func processUnassignedGarments(_ garments: [Garment]) {
        
        let descriptor = FetchDescriptor<LaundrySession>()
        var activeSessions = (try? context.fetch(descriptor)) ?? []
        
        let unassignedGarments = garments.filter {
            !$0.isBinAssigned && $0.isReadyToWash
        }
        guard !unassignedGarments.isEmpty else { return }
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
        
        save()
    }
    
    
    
    // MARK: - Laundry Session live
    
    
    
    // MARK: - Wash
    
    func startWashing(_ session: LaundrySession) {
        session.status           = .washing
        session.startDate        = .now
        
        let minutes    = session.suggestedProgram.washingTime // - 99 This is used for testing notification
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
    
    
    func pauseWashing(_ item: LaundrySession) {
        guard let endDate = item.completationDate else { return }
        
        let remaining = endDate.timeIntervalSinceNow
        if remaining > 0 {
            item.remainingTime = remaining
            
            LaundryActivityManager.shared.updateNotification(
                for          : item.id.uuidString,
                isPaused     : true,
                remainingTime: item.remainingTime,
                programName  : item.suggestedProgram.displayName
                
            )
            
        } else { item.remainingTime = 0 }
        
        item.completationDate = nil
        item.status = .paused
        
        save()
    }
    
    
    func resumeWashing(_ item: LaundrySession) {
        let timeToWash = item.remainingTime ?? 0
        
        item.completationDate = Date.now.addingTimeInterval(timeToWash)
        
        LaundryActivityManager.shared.updateNotification(
            for          : item.id.uuidString,
            isPaused     : false,
            remainingTime: timeToWash,
            programName  : item.suggestedProgram.displayName
        )
        
        item.remainingTime = nil
        item.status        = .washing
        
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
    
    
    func markAsComplete(_ session: LaundrySession) {
        session.status      = .completed
        session.isCompleted = true
        
        for garment in session.garments {
            garment.state                = .available
            garment.forceWash            = false
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
