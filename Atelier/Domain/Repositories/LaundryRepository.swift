//
//  LaundryRepository.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 07/04/2026.
//

import SwiftData

protocol LaundryRepositoryProtocol {
    func insert(_ session: LaundrySession) throws
    func delete(_ session: LaundrySession) throws
}

struct LaundryRepository: LaundryRepositoryProtocol {
    private let context: ModelContext
    
    init(context: ModelContext) {
        self.context = context
    }
    
    func insert(_ session: LaundrySession) throws {
        context.insert(session)
        try context.save()
    }
    
    func delete(_ session: LaundrySession) throws {
        context.delete(session)
        try context.save()
    }
    
}
