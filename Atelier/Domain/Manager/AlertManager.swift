//
//  AlertManager.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 07/04/2026.
//

import Observation

@Observable
final class AlertManager {
    var title    : String
    var message  : String
    var isPresent: Bool
    
    init() {
        self.title     = ""
        self.message   = ""
        self.isPresent = false
    }
}
