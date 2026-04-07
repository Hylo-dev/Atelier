//
//  LaundrySessionManaging.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 07/04/2026.
//

internal import Combine
import Foundation

protocol LaundrySessionManaging {
    
    var timerPulse: Publishers.Autoconnect<Timer.TimerPublisher> { get }
    
    func finishWashing(_ session: LaundrySession) throws
    func startWashing(_ session: LaundrySession) throws
    func pauseWashing(_ item: LaundrySession) throws
    func resumeWashing(_ item: LaundrySession) throws
    func cancelWashing(_ session: LaundrySession) throws
    
    func startDrying(_ session: LaundrySession) throws
    func cancelDrying(_ session: LaundrySession) throws
    func markAsComplete(_ session: LaundrySession) throws
}
