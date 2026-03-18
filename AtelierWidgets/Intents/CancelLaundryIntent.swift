//
//  CancelLaundryIntent.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 16/03/26.
//


import AppIntents
import ActivityKit
import Foundation
import UserNotifications

struct CancelLaundryIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Annulla Lavatrice"
    
    @Parameter(title: "Session ID")
    var sessionID: String
    
    init() {}
    init(sessionID: String) { self.sessionID = sessionID }
    
    @MainActor
    func perform() async throws -> some IntentResult {
        if let sharedDefaults = UserDefaults(
            suiteName: "group.com.hylo.team.Atelier"
        ) {
            sharedDefaults.set(sessionID, forKey: "canceledSessionID")
        }
        
        let activity = Activity<LaundryAttributes>.activities.first {
            $0.attributes.sessionID == self.sessionID
        }
        
        if let activity = activity {
            
            let finalState = LaundryAttributes.ContentState(
                interval: Date.now...Date.now
            )
            
            let finalContent = ActivityContent(
                state: finalState,
                staleDate: nil
            )
            
            stopNotification()
            await activity.end(finalContent, dismissalPolicy: .immediate)
            
        } else {
            print("Not found activity with ID: \(sessionID)")
        }
        
        return .result()
    }
    
    
    private func stopNotification() {
        Task { @MainActor in
            for activity in Activity<LaundryAttributes>.activities {
                let id = activity.id

                await activity.end(nil, dismissalPolicy: .immediate)
                UNUserNotificationCenter.current().removePendingNotificationRequests(
                    withIdentifiers: [id]
                )
            }
        }
    }
}
