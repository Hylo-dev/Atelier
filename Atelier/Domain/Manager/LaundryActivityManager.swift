//
//  LaundryActivityManager.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 16/03/26.
//


import Foundation
import ActivityKit
import UserNotifications

@MainActor
final class LaundryActivityManager {
    static  let shared = LaundryActivityManager()
    private var activity: Activity<LaundryAttributes>?
    
    
    
    func start(
        programName: String,
        startDate  : Date,
        targetDate : Date,
        sessionId  : String,
        temperature: Int
    ) {
        let interval     = startDate...targetDate
        let initialState = LaundryAttributes.ContentState(interval: interval)
        
        let attributes = LaundryAttributes(
            programName: programName,
            temperature: temperature,
            sessionID  : sessionId
        )
        
        Task {
            for existingActivity in Activity<LaundryAttributes>.activities {
                await existingActivity.end(nil, dismissalPolicy: .immediate)
            }
            
            do {
                let currentActivity = try Activity.request(
                    attributes: attributes,
                    content: .init(state: initialState, staleDate: targetDate)
                )
                self.activity = currentActivity
                
                let timeRemaining = targetDate.timeIntervalSince(Date.now)
                if timeRemaining > 0 {
                    scheduleNotification(
                        for      : currentActivity.id,
                        in       : timeRemaining,
                        program  : programName,
                        sessionId: sessionId
                    )
                }
                
            } catch {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    
    
    func setupNotifications() {
        let category = UNNotificationCategory(
            identifier       : "LAUNDRY_CATEGORY",
            actions          : [],
            intentIdentifiers: [],
            options          : []
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }
    
    
    private func scheduleNotification(
        for activityId: String,
        in  seconds   : TimeInterval,
            program   : String,
            sessionId : String
    ) {
        let content = UNMutableNotificationContent()
        
        content.title              = "Cycle Complete"
        content.body               = "The \(program) cycle has finished"
        content.categoryIdentifier = "LAUNDRY_CATEGORY"
        content.userInfo           = ["ACTIVITY_ID": activityId, "SESSION_ID": sessionId]
        content.sound              = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)
        let request = UNNotificationRequest(identifier: activityId, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    
    func updateNotification(
        for activityId   : String,
        isPaused     : Bool,
        remainingTime: TimeInterval?,
        programName  : String,
        sessionId    : String
    ) {
        if isPaused {
            UNUserNotificationCenter.current().removePendingNotificationRequests(
                withIdentifiers: [activityId]
            )
            print("Paused Notification")
            
        } else if let remaining = remainingTime, remaining > 0 {
            scheduleNotification(
                for: activityId,
                in: remaining,
                program: programName,
                sessionId: sessionId
            )
            print("Reprogramed Notification")
        }
    }
    
    
    func stop() {
        Task {
            for activity in Activity<LaundryAttributes>.activities {
                await activity.end(nil, dismissalPolicy: .immediate)
            }
        }
    }
}
