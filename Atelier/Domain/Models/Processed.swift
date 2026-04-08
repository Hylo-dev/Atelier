//
//  ProcessedOutfits.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 08/04/2026.
//

import SwiftData

struct Processed<T: PersistentModel> {
    let visible: [T]
    let grouped: [String: [T]]
    let brands : [String]
    let tag    : [String]
    
    init(
        visible: [T],
        grouped: [String : [T]],
        brands : [String] = [],
        tag    : [String]
    ) {
        self.visible = visible
        self.grouped = grouped
        self.brands  = brands
        self.tag     = tag
    }
    
    init() {
        self.visible = []
        self.grouped = [:]
        self.brands  = []
        self.tag     = []
    }
}
