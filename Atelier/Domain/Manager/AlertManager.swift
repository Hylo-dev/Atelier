//
//  AlertManager.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 07/04/2026.
//

import Observation

protocol AlertManaging {
    var title    : String { get set }
    var message  : String { get set }
    var isPresent: Bool   { get set }
}

@Observable
final class AlertManager: AlertManaging {
    var title    : String
    var message  : String
    var isPresent: Bool
    
    init() {
        self.title     = ""
        self.message   = ""
        self.isPresent = false
    }
}
