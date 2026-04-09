//
//  GarmentDTO.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 09/04/2026.
//

import SwiftData

struct GarmentDTO: DTO {
    let id         : PersistentIdentifier
    let firstLabel : String?
    let secondLabel: String
}
