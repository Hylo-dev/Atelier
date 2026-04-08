//
//  GarmentProcessing.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 07/04/2026.
//

protocol GarmentProcessing {    
    func processGarments(
        _ garments    : [Garment],
        state         : TabFilterService,
        with viewModel: WardrobeViewModel
    )
}
