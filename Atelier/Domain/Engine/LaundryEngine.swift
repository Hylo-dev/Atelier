//
//  LaundryEngine.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 11/03/26.
//

import Foundation

struct LaundryEngine {
    
    private static let defaultRules: [LaundrySortingRule] = [
        ProfessionalCareRule(),
        WoolAndCashmereRule(),
        DenimRule(),
        ColorMatrixRule()
    ]
    
    private let rules: [LaundrySortingRule]
    
    init(rules: [LaundrySortingRule] = Self.defaultRules) {
        self.rules = rules
    }
    
    func process(_ garment: Garment) -> (
        bin: LaundryBin,
        targetTemperature: Int,
        suggestedProgram: Program
    ) {
        let targetBin = self.rules.lazy.compactMap {
            $0.evaluate(garment)
        }.first ?? .vibrantNormal
        
        let idealTemp = garment.washingSymbols
            .compactMap { $0.maxWashingTemperature }
            .min() ?? 40
        
        var suggestedProgram: Program = .standard
        let symbols = garment.washingSymbols
        
        if symbols.contains(where: { $0 == .doNotMachineWash }) {
            return (targetBin, idealTemp, .notWash)
        }
        
        if symbols.contains(where: { $0 == .handWash }) {
            return (targetBin, idealTemp, .handWash)
        }
        
        let animalFiberPct = garment.composition
            .filter { $0.fabric == .wool || $0.fabric == .cashmere }
            .reduce(0) { $0 + $1.percentual }
        
        if animalFiberPct >= 15 {
            return (targetBin, idealTemp, .wool)
        }
        
        let delicateFiberPct = garment.composition
            .filter { $0.fabric == .silk ||
                $0.fabric == .acrylic ||
                $0.fabric == .nylon ||
                $0.fabric == .polyester ||
                $0.fabric == .spandex ||
                $0.fabric == .viscose
            }
            .reduce(0) { $0 + $1.percentual }
        
        if symbols.contains(
            where: { $0.agitationLevel == .gentle }
        ) || delicateFiberPct > 30 {
            suggestedProgram = .delicate
            
        } else if symbols.contains(where: { $0.agitationLevel == .reduced }) {
            suggestedProgram = .mix
            
        } else if WashingColorGroup.classify(garment.color) == .darks {
            suggestedProgram = .darks
        }
        
        return (targetBin, idealTemp, suggestedProgram)
    }
}
