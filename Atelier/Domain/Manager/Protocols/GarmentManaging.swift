//
//  GarmentManaging.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 07/04/2026.
//


protocol GarmentManaging: Manager where T == Garment {
    func insert(_ item: Garment) throws
    func update() throws
}
