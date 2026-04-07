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
final class LaundryActivityManager: LaundryActivityProviding {
//    private var activity: Activity<LaundryAttributes>?
    
    
    
    func start(
        programName: String,
        startDate  : Date,
        targetDate : Date,
        sessionId  : String,
        temperature: Int
    ) {
//        let interval     = startDate...targetDate
//        let initialState = LaundryAttributes.ContentState(interval: interval)
        
//        let attributes = LaundryAttributes(
//            programName: programName,
//            temperature: temperature,
//            sessionID  : sessionId
//        )
        
        Task {
//            for existingActivity in Activity<LaundryAttributes>.activities {
//                await existingActivity.end(nil, dismissalPolicy: .immediate)
//            }
            
            let timeRemaining = targetDate.timeIntervalSince(Date.now)
            if timeRemaining > 0 {
                scheduleNotification(
                    for    : sessionId,
                    in     : timeRemaining,
                    program: programName
                )
            }
            
//            do {
//                let currentActivity = try Activity.request(
//                    attributes: attributes,
//                    content: .init(state: initialState, staleDate: targetDate)
//                )
//                self.activity = currentActivity
                
                
                
//            } catch {
//                print("Error: \(error.localizedDescription)")
//            }
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
        for id: String,
        in  seconds   : TimeInterval,
            program   : String
    ) {
        let content = UNMutableNotificationContent()
        
        content.title              = "Cycle Complete"
        content.body               = "The \(program) cycle has finished"
        content.categoryIdentifier = "LAUNDRY_CATEGORY"
//        content.userInfo           = ["ACTIVITY_ID": activityId, "SESSION_ID": sessionId]
        content.userInfo           = ["SESSION_ID": id]
        content.sound              = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: seconds,
            repeats     : false
        )
        let request = UNNotificationRequest(
            identifier: id,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    
    func updateNotification(
        for id            : String,
            isPaused      : Bool,
            remainingTime : TimeInterval?,
            programName   : String
    ) {
        if isPaused {
            UNUserNotificationCenter.current().removePendingNotificationRequests(
                withIdentifiers: [id]
            )
            print("Paused Notification")
            
        } else if let remaining = remainingTime, remaining > 0 {
            scheduleNotification(
                for    : id,
                in     : remaining,
                program: programName
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
