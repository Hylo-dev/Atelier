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
internal import Combine

protocol ApplianceProcessGarmentProtocol {
    func processUnassignedGarments(_ garments: [Garment]) throws
    func unassignGarment(_ garment: Garment) throws
    
    func detachGarment(
        _    garment: Garment,
        from session: LaundrySession
    ) throws
}

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

@MainActor
@Observable
final class ApplianceManager: Manager, ApplianceProcessGarmentProtocol, LaundrySessionManaging {
    
    private let context: ModelContext
    
    private let repository: LaundryRepositoryProtocol
    private let assignmentService: LaundryAssignmentManaging
    private let controlService: LaundryControlManaging
    
    var timerPulse: Publishers.Autoconnect<Timer.TimerPublisher> {
        controlService.timerPulse
    }
    
    init(
        _ context        : ModelContext,
        repository       : LaundryRepositoryProtocol? = nil,
        assignmentService: LaundryAssignmentManaging = LaundryAssignmentService(),
        controlService  : LaundryControlManaging = LaundryControlService()
    ) {
        self.context = context
        self.repository = repository ?? LaundryRepository(context: context)
        self.assignmentService = assignmentService
        self.controlService = controlService
    }
    
    
    func insert(_ element: LaundrySession) throws {
        try repository.insert(element)
    }
    
    func update() throws {
        try context.save()
    }
    
    func delete(_ element: LaundrySession) throws {
        try repository.delete(element)
    }
    
    
    // MARK: Garment handlers
    
    func detachGarment(
        _    garment: Garment,
        from session: LaundrySession
    ) throws {
        try assignmentService.detachGarment(
            garment,
            from: session,
            in: context
        )
    }
    
    func unassignGarment(_ garment: Garment) throws {
        try assignmentService.unassignGarment(garment, in: context)
    }
    
    
    func processUnassignedGarments(_ garments: [Garment]) throws {
        try assignmentService.processUnassignedGarments(
            garments,
            in: context
        )
    }
    
    
    // MARK: - Wash
    
    func startWashing(_ session: LaundrySession) throws {
        try controlService.startWashing(session)
        try context.save()
    }
    
    
    func pauseWashing(_ item: LaundrySession) throws {
        try controlService.pauseWashing(item)
        try context.save()
    }
    
    
    func resumeWashing(_ item: LaundrySession) throws {
        try controlService.resumeWashing(item)
        try context.save()
    }
    
    
    func cancelWashing(_ session: LaundrySession) throws {
        try controlService.cancelWashing(session)
        try context.save()
    }
    
    
    
    func finishWashing(_ session: LaundrySession) throws {
        try controlService.finishWashing(session)
        try context.save()
    }
    
    
    
    // MARK: Dry
    
    func startDrying(_ session: LaundrySession) throws {
        try controlService.startDrying(session)
        try context.save()
    }
    
    
    
    func cancelDrying(_ session: LaundrySession) throws {
        try controlService.cancelDrying(session)
        try context.save()
    }
    
    
    func markAsComplete(_ session: LaundrySession) throws {
        try controlService.markAsComplete(session)
        try context.save()
    }
    
    
    func finishWashingSession(id: UUID) throws {
        let descriptor = FetchDescriptor<LaundrySession>(
            predicate: #Predicate { $0.id == id }
        )
        
        if let session = try context.fetch(descriptor).first {
            try finishWashing(session)
        }
    }
    
    // MARK: Handlers
    
    func stopLiveActivity(_ session: LaundrySession) {
        controlService.stopLiveActivity(session)
    }
}
