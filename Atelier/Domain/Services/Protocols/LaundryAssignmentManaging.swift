//
//  LaundryAssignmentManaging.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 07/04/2026.
//

import SwiftData


protocol LaundryAssignmentManaging {
    func processUnassignedGarments(
        _  garments: [Garment],
        in context : ModelContext
    ) throws
    
    func unassignGarment(
        _  garment: Garment,
        in context: ModelContext
    ) throws
    
    func detachGarment(
        _ garment   : Garment,
        from session: LaundrySession,
        in context  : ModelContext
    ) throws
}
