//
//  LaundryControlManaging.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 07/04/2026.
//

import Observation
import Foundation
import UserNotifications
internal import Combine

@Observable
final class LaundryControlService: LaundryControlManaging {
    private let activityProvider: LaundryActivityProviding
    
    let timerPulse = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    init(activityProvider: LaundryActivityProviding = LaundryActivityManager()) {
        self.activityProvider = activityProvider
    }

    // MARK: - Wash
    
    func startWashing(_ session: LaundrySession) throws {
        session.status           = .washing
        session.startDate        = .now
        
        let minutes    = session.suggestedProgram.washingTime // - 99 This is used for testing notification
        let targetDate = Calendar.current.date(byAdding: .minute, value: minutes, to: .now) ?? .now
        session.completationDate = targetDate
        
        for garment in session.garments {
            garment.state = .washing
        }
        
        activityProvider.start(
            programName: session.suggestedProgram.displayName,
            startDate  : session.startDate ?? .now,
            targetDate : targetDate,
            sessionId  : session.id.uuidString,
            temperature: session.targetTemperature
        )
        
         
    }
    
    
    func pauseWashing(_ item: LaundrySession) throws {
        guard let endDate = item.completationDate else { return }
        
        let remaining = endDate.timeIntervalSinceNow
        if remaining > 0 {
            item.remainingTime = remaining
            
            activityProvider.updateNotification(
                for          : item.id.uuidString,
                isPaused     : true,
                remainingTime: item.remainingTime,
                programName  : item.suggestedProgram.displayName
                
            )
            
        } else { item.remainingTime = 0 }
        
        item.completationDate = nil
        item.status = .paused
        
         
    }
    
    
    func resumeWashing(_ item: LaundrySession) throws {
        let timeToWash = item.remainingTime ?? 0
        
        item.completationDate = Date.now.addingTimeInterval(timeToWash)
        
        activityProvider.updateNotification(
            for          : item.id.uuidString,
            isPaused     : false,
            remainingTime: timeToWash,
            programName  : item.suggestedProgram.displayName
        )
        
        item.remainingTime = nil
        item.status        = .washing
        
         
    }
    
    
    func cancelWashing(_ session: LaundrySession) throws {
        session.status           = .planned
        session.startDate        = nil
        session.completationDate = nil
        
        for garment in session.garments {
            garment.state = .toWash
        }
        
        stopLiveActivity(session)
         
    }
    
    
    
    func finishWashing(_ session: LaundrySession) throws {
        session.status = .clean
        
        for garment in session.garments {
            garment.state = .drying
        }
        
        stopLiveActivity(session)
         
    }
    
    
    
    // MARK: Dry
    
    func startDrying(_ session: LaundrySession) throws {
        session.status = .drying
         
    }
    
    
    
    func cancelDrying(_ session: LaundrySession) throws {
        session.status = .clean
         
    }
    
    
    func markAsComplete(_ session: LaundrySession) throws {
        session.status           = .completed
        session.isCompleted      = true
        session.completationDate = .now
        
        for garment in session.garments {
            garment.state                = .available
            garment.forceWash            = false
            garment.isBinAssigned        = false
            garment.wearCount            = 0
            garment.lastWashingDate      = .now
        }
        
         
    }
    
    // MARK: Handlers
    
    func stopLiveActivity(_ session: LaundrySession) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [session.id.uuidString]
        )
        
        activityProvider.stop()
    }
}
