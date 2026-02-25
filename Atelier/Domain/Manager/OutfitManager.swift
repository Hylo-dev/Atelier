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
final class OutfitManager {
    var context: ModelContext
    
    init(context: ModelContext) {
        self.context = context
    }
    
    @inline(__always)
    func createOutfit(_ outfit: Outfit) {
        context.insert(outfit)
        
        save()
    }
    
    @inline(__always)
    func updateOutfit() {
        save()
    }
    
    @inline(__always)
    func deleteOutfit(_ outfit: Outfit) {
        self.context.delete(outfit)
        save()
    }
    
    @inline(__always)
    private func save() {
        try? context.save()
    }
}
