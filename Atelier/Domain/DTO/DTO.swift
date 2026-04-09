//
//  DTO.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 09/04/2026.
//

import SwiftData

nonisolated protocol DTO: Sendable {
    var id         : PersistentIdentifier { get }
    var firstLabel : String?              { get }
    var secondLabel: String               { get }
}
