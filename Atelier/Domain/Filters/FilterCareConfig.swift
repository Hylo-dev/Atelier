//
//  FilterCareConfig.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 19/04/2026.
//

import Foundation

struct FilterCareConfig: @MainActor FilterProtocol {
    typealias T = LaundrySession
    
    var isFiltering: Bool {
        true
    }
    
    init() {
        
    }
    
    mutating func reset() {
        
    }
    
    func generatePredicate() -> Predicate<LaundrySession> {
        return #Predicate { val in
            val.isCompleted
        }
    }
}
