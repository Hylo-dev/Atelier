//
//  LaundryActivityManager.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 16/03/26.
//


import Foundation
import ActivityKit

@MainActor
final class LaundryActivityManager {
    static let shared = LaundryActivityManager()
    private var activity: Activity<LaundryAttributes>?
    
    
    func start(
        programName: String,
        startDate  : Date,
        targetDate : Date,
        sessionId  : String,
        temperature: Int
    ) {
        let interval = startDate...targetDate
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
                self.activity = try Activity.request(
                    attributes: attributes,
                    content: .init(state: initialState, staleDate: nil)
                )
                                
                let timeRemaining = targetDate.timeIntervalSince(Date.now)
                if timeRemaining > 0 {
                    try? await Task.sleep(nanoseconds: UInt64(timeRemaining * 1_000_000_000))
                    
                    let alertConfig = AlertConfiguration(
                        title: "Lavatrice Terminata",
                        body: "Il programma \(programName) è finito!",
                        sound: .default
                    )
                                        
                    await self.activity?.update(
                        ActivityContent(state: initialState, staleDate: nil),
                        alertConfiguration: alertConfig
                    )
                }
                
            } catch {
                print("Error Live Activity: \(error.localizedDescription)")
            }
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
