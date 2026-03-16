//
//  LaundryAttributes.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 16/03/26.
//


import ActivityKit
import Foundation

struct LaundryAttributes: ActivityAttributes {
    
    public struct ContentState: Codable, Hashable {
        var interval      : ClosedRange<Date>
        var isPaused      : Bool = false
        var pausedTimeLeft: TimeInterval? = nil
        var pausedProgress: Double = 0.0
    }

    var programName: String
    var temperature: Int
    var sessionID  : String
}
