//
//  GarmentManager.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 16/02/26.
//

import Observation
import SwiftData

@Observable
@MainActor
final class GarmentManager: Manager {
    var context: ModelContext
    
    
    
    init(_ context: ModelContext) {
        self.context = context
    }
    
    
    
    @inline(__always)
    func insert(_ element: Garment) {
        context.insert(element)
        save()
    }
    
    
    
    @inline(__always)
    func update() {
        save()
    }
    
    
    
    @inline(__always)
    func delete(_ garment: Garment) {
        self.context.delete(garment)
        save()
    }
    
    
    
    @inline(__always)
    internal func save() {
        do {
            try context.save()
            
        } catch {
            print("Error DB: \(error)")
        }
    }
}
