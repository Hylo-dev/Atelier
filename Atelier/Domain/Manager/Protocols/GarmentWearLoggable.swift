//
//  GarmentWearLoggableProtocol.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 07/04/2026.
//


protocol GarmentWearLoggable: Manager<Garment> {
    func logWear(
        for item  : Garment,
        each count: Int
    ) -> Bool
    
    func setWashState(
        for  item   : Garment,
        used manager: ApplianceProcessing
    ) throws
    
    func resetWear(
        for  item   : Garment,
        used manager: ApplianceProcessing
    ) throws
}
