//
//  Untitled.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 17/02/26.
//

import Observation
import SwiftData

@Observable
@MainActor
final class OutfitManager: Manager {
    var context: ModelContext
    
    init(_ context: ModelContext) {
        self.context = context
    }
    
    @inline(__always)
    func insert(_ element: Outfit) {
        context.insert(element)
        
        save()
    }
    
    @inline(__always)
    func update() {
        save()
    }
    
    @inline(__always)
    func delete(_ element: Outfit) {
        self.context.delete(element)
        save()
    }
    
    @inline(__always)
    internal func save() {
        try? context.save()
    }
}
