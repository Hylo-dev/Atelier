//
//  GarmentProcessing.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 07/04/2026.
//

protocol GarmentProcessing {    
    func process(_ garments: [Garment]) -> Processed<Garment>
}
