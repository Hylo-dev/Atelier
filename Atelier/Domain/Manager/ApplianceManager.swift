//
//  ApplianceManager.swift
//  Atelier
//
//  Created by C4V4H.exe on 18/02/26.
//  Modified by eliorodr2104 on 07/04/26.
//

import SwiftData
import UserNotifications
internal import Combine


@MainActor
@Observable
final class ApplianceManager: Manager, ApplianceProcessing, LaundrySessionManaging, WashingSessionManaging {
    
    private let context: ModelContext
    
    private let repository: LaundryRepositoryProtocol
    private let assignmentService: LaundryAssignmentManaging
    private let controlService: LaundryControlManaging
    
    var timerPulse: Publishers.Autoconnect<Timer.TimerPublisher>
    
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
        self.timerPulse = controlService.timerPulse
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
}
