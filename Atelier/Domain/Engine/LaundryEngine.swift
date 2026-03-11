//
//  LaundryEngine.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 11/03/26.
//

import Foundation

struct LaundryEngine {
    
    private static let rules: [LaundrySortingRule] = [
        ProfessionalCareRule(),
        WoolAndCashmereRule(),
        DenimRule(),
        ColorMatrixRule()
    ]
    
    func process(_ garment: Garment) -> (
        bin: LaundryBin,
        targetTemperature: Int,
        suggestedProgram: Program
    ) {
        let targetBin = Self.rules.lazy.compactMap {
            $0.evaluate(garment)
        }.first ?? .vibrantNormal
        
        let idealTemp = garment.washingSymbols
            .compactMap { $0.maxWashingTemperature }
            .min() ?? 40
        
        let levels = garment.washingSymbols.map { $0.agitationLevel }
        var idealAgitation: WashingAgitation = .normal
        
        if levels.contains(.gentle) {
            idealAgitation = .gentle
            
        } else if levels.contains(.reduced) {
            idealAgitation = .reduced
        }
        
        return (targetBin, idealTemp, idealAgitation.program)
    }
}
