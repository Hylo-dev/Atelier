//
//  SessionDTO.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 19/04/2026.
//

import SwiftData

struct SessionDTO: DTO {
    let id         : PersistentIdentifier
    let firstLabel : String?
    let secondLabel: String
}
