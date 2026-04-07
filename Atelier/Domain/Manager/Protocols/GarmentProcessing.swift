//
//  GarmentProcessing.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 07/04/2026.
//

protocol GarmentProcessing {
    var availableCategories: [String] { get set }
    
    func processGarments(
        _ garments: [Garment],
        with filterManager: any FilterProtocol<Garment>
    )
}
