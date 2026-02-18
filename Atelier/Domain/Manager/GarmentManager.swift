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
final class GarmentManager {
    var context: ModelContext
    
    init(context: ModelContext) {
        self.context = context
    }
    
    func addGarment(_ value: Garment) {
        context.insert(value)
        save()
    }
    
    func updateGarment() {
        save()
    }
    
    func deleteGarment(_ garment: Garment) {
        self.context.delete(garment)
        save()
    }
    
    private func save() {
        do {
            try context.save()
            
        } catch {
            print("Error DB: \(error)")
        }
    }
}
