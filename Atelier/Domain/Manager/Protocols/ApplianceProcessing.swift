//
//  ApplianceProcessing.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 07/04/2026.
//


protocol ApplianceProcessing {
    func processUnassignedGarments(_ garments: [Garment]) throws
    func unassignGarment(_ garment: Garment) throws
    
    func detachGarment(
        _    garment: Garment,
        from session: LaundrySession
    ) throws
}
