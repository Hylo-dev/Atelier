//
//  GarmentManager.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 16/02/26.
//

import SwiftData
import Foundation

@Observable
final class GarmentManager {
    var context: ModelContext
    
    init(context: ModelContext) {
        self.context = context
    }
    
    func addGarment(_ value: Garment) {
        context.insert(value)
        save()
    }
    
//    func updateGarment(
//        _ garment: Garment,
//        newName: String,
//        newSize: String
//    ) {
//        garment.name = newName
//        garment.size = newSize
//        
//        save()
//    }
    
    func deleteGarment(_ garment: Garment) {
        context.delete(garment)
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
