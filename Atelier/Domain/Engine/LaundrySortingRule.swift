//
//  LaundrySortingRule.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 11/03/26.
//

protocol LaundrySortingRule {
    func evaluate(_ garment: Garment) -> LaundryBin?
}

struct ProfessionalCareRule: LaundrySortingRule {
    func evaluate(_ garment: Garment) -> LaundryBin? {
        let leatherSuede = garment.totalPercentage(of: [.leather, .suede])
        let needsDryCleaning = garment.washingSymbols.contains {
            $0 == .doNotMachineWash || $0 == .dryClean || $0 == .dryCleanAnySolvent || $0 == .dryCleanPCE || $0 == .dryCleanHydrocarbon
        }
        
        if leatherSuede >= 1.0 || needsDryCleaning {
            return .professionalCare
        }
        return nil
    }
}

struct WoolAndCashmereRule: LaundrySortingRule {
    func evaluate(_ garment: Garment) -> LaundryBin? {
        if garment.totalPercentage(of: [.wool, .cashmere]) >= 10.0 {
            return .woolAndCashmere
        }
        return nil
    }
}

struct DenimRule: LaundrySortingRule {
    func evaluate(_ garment: Garment) -> LaundryBin? {
        if garment.subCategory == .jeans || garment.totalPercentage(of: [.denim]) >= 50.0 {
            return .denim
        }
        return nil
    }
}

struct ColorMatrixRule: LaundrySortingRule {
    func evaluate(_ garment: Garment) -> LaundryBin? {
        
        // Calcoli "on the fly" presi dalle tue vecchie computed properties
        let hasCriticalDelicateFibers = garment.totalPercentage(of: [.silk, .wool, .cashmere]) >= 10.0
        let isDelicate = garment.washingSymbols.contains(where: { $0.isDelicate }) ||
        hasCriticalDelicateFibers ||
        garment.category == .lingerie ||
        garment.category == .onePiece
        
        let isHeavyDutyNatural = garment.totalPercentage(of: [.cotton, .linen, .hemp]) >= 85.0
        
        let isSyntheticDominant = garment.totalPercentage(of: .synthetic) > 50.0
        let isActivewear = isSyntheticDominant && (garment.style == .sporty || garment.totalPercentage(of: [.fleece]) >= 20.0 || garment.subCategory == .sportsBras)
        
        let colorGroup = WashingColorGroup.from(hex: garment.color)
        
        switch colorGroup {
            case .whites:
                if isDelicate { return .whiteDelicate }
                return isHeavyDutyNatural ? .whiteHeavyDuty : .whiteNormal
                
            case .darks:
                if isDelicate { return .darkDelicate }
                return .darkNormal
                
            case .pastels:
                if isDelicate { return .pastelDelicate }
                return .pastelNormal
                
            case .vibrant:
                if isActivewear { return .activewear }
                if isDelicate { return .vibrantDelicate }
                return .vibrantNormal
        }
    }
}
