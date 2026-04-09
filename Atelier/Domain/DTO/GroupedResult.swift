//
//  GroupedResult.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 09/04/2026.
//

import SwiftData

struct GroupedResult: Sendable {
    let brands    : [String]
    let tags      : [String]
    let groupedIDs: [String: [PersistentIdentifier]]
}
