//
//  FilterManager.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 09/04/2026.
//


import Foundation
import Observation

@Observable
class FilterManager {
    private(set) var predicate: Predicate<Garment> = #Predicate { _ in true }
    
    var config = FilterGarmentConfig() {
        didSet {
            guard config != oldValue else { return }
            predicate = config.generatePredicate()
        }
    }
    
    func resetFilters() {
        config = FilterGarmentConfig()
    }
}
