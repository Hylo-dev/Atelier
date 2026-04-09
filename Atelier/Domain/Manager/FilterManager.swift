//
//  FilterManager.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 09/04/2026.
//


import Foundation
import Observation
import SwiftData

@Observable
class FilterManager<Config: FilterProtocol> {
    
    private(set) var predicate: Predicate<Config.T> = #Predicate { _ in true }
    
    var config: Config
    var isFiltering: Bool { config.isFiltering }
    
    init(config: Config = Config()) {
        self.config = config
    }
    
    func resetFilters() {
        config.reset()
    }
    
    func update() {
        predicate = config.generatePredicate()
    }
}
