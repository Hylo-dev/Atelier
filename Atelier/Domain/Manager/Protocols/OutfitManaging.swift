//
//  OutfitManaging.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 07/04/2026.
//


protocol OutfitManaging: Manager where T == Outfit {
    func insert(_ item: Outfit) throws
    func update() throws
}
