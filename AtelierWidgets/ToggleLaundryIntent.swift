//
//  ToggleLaundryIntent.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 16/03/26.
//


import AppIntents
import ActivityKit

struct ToggleLaundryIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Pause/Resume Washing"
    
    @Parameter(title: "Session ID")
    var sessionID: String
    
    init() {}
    init(sessionID: String) { self.sessionID = sessionID }
    
    @MainActor
    func perform() async throws -> some IntentResult {
        let activity = Activity<LaundryAttributes>.activities.first { $0.attributes.sessionID == sessionID }
        
        guard let activity = activity else { return .result() }
        let currentState = activity.content.state
        
        var newState: LaundryAttributes.ContentState
        
        if currentState.isPaused {
            let timeLeft = currentState.pausedTimeLeft ?? 0
            let newEndDate = Date.now.addingTimeInterval(timeLeft)
            
            let totalDuration = currentState.interval.upperBound.timeIntervalSince(currentState.interval.lowerBound)
            let newStartDate = newEndDate.addingTimeInterval(-totalDuration)
            
            newState = LaundryAttributes.ContentState(
                interval: newStartDate...newEndDate,
                isPaused: false,
                pausedTimeLeft: nil,
                pausedProgress: 0.0
            )
            
        } else {
            let timeLeft = currentState.interval.upperBound.timeIntervalSinceNow
            
            let totalDuration = currentState.interval.upperBound.timeIntervalSince(currentState.interval.lowerBound)
            
            let progress = totalDuration > 0 ? max(0, min(timeLeft / totalDuration, 1.0)) : 0.0
            
            newState = LaundryAttributes.ContentState(
                interval: currentState.interval,
                isPaused: true,
                pausedTimeLeft: max(0, timeLeft),
                pausedProgress: progress
            )
        }
        
        await activity.update(ActivityContent(state: newState, staleDate: nil))
        return .result()
    }
}
