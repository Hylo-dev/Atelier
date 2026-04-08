//
//  ProcessedOutfits.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 08/04/2026.
//


struct ProcessedOutfits {
    let visible: [Outfit]
    let grouped: [String: [Outfit]]
    let seasons: [String]
    
    init(
        visible: [Outfit],
        grouped: [String : [Outfit]],
        seasons: [String]
    ) {
        self.visible = visible
        self.grouped = grouped
        self.seasons = seasons
    }
    
    init() {
        self.visible = []
        self.grouped = [:]
        self.seasons = []
    }
}
