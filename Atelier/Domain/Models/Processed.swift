//
//  ProcessedOutfits.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 08/04/2026.
//

import SwiftData

struct Processed<T: PersistentModel> {
    let grouped: [String: [T]]
    let brands : [String]
    let tag    : [String]
    
    init(
        grouped: [String : [T]],
        brands : [String] = [],
        tag    : [String]
    ) {
        self.grouped = grouped
        self.brands  = brands
        self.tag     = tag
    }
    
    init() {
        self.grouped = [:]
        self.brands  = []
        self.tag     = []
    }
}
