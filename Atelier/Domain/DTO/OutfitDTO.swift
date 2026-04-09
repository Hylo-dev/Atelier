//
//  OutfitDTO.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 09/04/2026.
//

import SwiftData

struct OutfitDTO: DTO {
    let id         : PersistentIdentifier
    let firstLabel : String?
    let secondLabel: String
    
    init(
        id         : PersistentIdentifier,
        firstLabel : String? = nil,
        secondLabel: String
    ) {
        self.id = id
        self.firstLabel = firstLabel
        self.secondLabel = secondLabel
    }
}
