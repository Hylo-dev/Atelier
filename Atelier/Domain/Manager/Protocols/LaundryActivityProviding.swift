//
//  LaundryActivityProviding.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 07/04/2026.
//


import Foundation

protocol LaundryActivityProviding {
    func start(
        programName: String,
        startDate: Date,
        targetDate: Date,
        sessionId: String,
        temperature: Int
    )
    
    func updateNotification(
        for id: String,
        isPaused: Bool,
        remainingTime: TimeInterval?,
        programName: String
    )
    
    func setupNotifications()
    func stop()
}