//
//  LaundryEnums.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 11/03/26.
//

enum LaundryCategory: String, CaseIterable, Identifiable {
    case washing      = "Washing"
    case bleaching    = "Bleaching"
    case drying       = "Drying"
    case ironing      = "Ironing"
    case professional = "Professional Care"
    
    var id: String { rawValue }
}



enum LaundrySymbol: String, Codable, SelectableItem {
    
    // MARK: - Washing
    case machineWashNormal         = "machine_wash_normal"
    
    case machineWashCold           = "machine_wash_cold"
    case machineWashWarm           = "machine_wash_warm"
    case machineWashHot            = "machine_wash_hot"
    case machineWashVeryHot        = "machine_wash_very_hot"
    
    case machineWashDelicate       = "machine_wash_delicate"
    case machineWashPermanentPress = "machine_wash_permanent_press"
    case handWash                  = "hand_wash"
    case doNotMachineWash          = "do_not_machine_wash"
    case doNotWring                = "do_not_wring"
    
    // MARK: - Bleaching
    case bleach                    = "bleach"
    case bleachNonChlorine         = "bleach_non_chlorine"
    case doNotBleach               = "do_not_bleach"
    
    // MARK: - Drying
    case tumbleDryNormal           = "tumble_dry_normal"
    case tumbleDryLow              = "tumble_dry_low"
    case tumbleDryMedium           = "tumble_dry_medium"
    case tumbleDryHigh             = "tumble_dry_high"
    case tumbleDryNoHeat           = "tumble_dry_no_heat"
    case tumbleDryDelicate         = "tumble_dry_delicate"
    case tumbleDryPermanentPress   = "tumble_dry_permanent_press"
    case doNotTumbleDry            = "do_not_tumble_dry"
    
    case hangDry                   = "hang_dry"
    case dripDry                   = "drip_dry"
    case dryFlat                   = "dry_flat"
    case dryInShade                = "dry_in_shade"
    
    // MARK: - Ironing
    case ironLow                   = "iron_low"
    case ironMedium                = "iron_medium"
    case ironHigh                  = "iron_high"
    case ironNoSteam               = "iron_no_steam"
    case doNotIron                 = "do_not_iron"
    
    // MARK: - Professional / Dry Clean
    case dryClean                  = "dry_clean"
    case dryCleanAnySolvent        = "dry_clean_any_solvent"
    case dryCleanHydrocarbon       = "dry_clean_hydrocarbon_solvent_only"
    case dryCleanPCE               = "dry_clean_tetrachloroethylene_solvent_only"
    case doNotDryClean             = "do_not_dry_clean"
    case professionalWetCleaning   = "professional_wet_cleaning_only"
    
    init?(createMLLabel: String) {
        // 1. Tenta prima il match diretto (se l'etichetta è identica al rawValue)
        if let directMatch = LaundrySymbol(rawValue: createMLLabel) {
            self = directMatch
            return
        }
        
        // 2. Mappa le etichette specifiche di CreateML ai tuoi casi
        switch createMLLabel {
                
                // MARK: - Temperature
                // Mappiamo i gradi alle tue costanti (basandoci sulla tua logica di maxWashingTemperature)
            case "30C": self = .machineWashCold
            case "40C": self = .machineWashWarm
            case "50C", "60C": self = .machineWashHot // 60C lo consideriamo Hot
            case "70C", "95C": self = .machineWashVeryHot
                
                // MARK: - Do Not (DN_...)
            case "DN_bleach": self = .doNotBleach
            case "DN_dry", "DN_tumble_dry": self = .doNotTumbleDry
            case "DN_dry_clean": self = .doNotDryClean
            case "DN_iron": self = .doNotIron
            case "DN_steam": self = .ironNoSteam
            case "DN_wash": self = .doNotMachineWash
            case "DN_wring": self = .doNotWring
                
                // MARK: - Bleaching
            case "chlorine_bleach": self = .bleach
            case "non_chlorine_bleach": self = .bleachNonChlorine
                
                // MARK: - Drying
            case "line_dry", "natural_dry": self = .hangDry
            case "line_dry_in_shade", "shade_dry": self = .dryInShade
                
                // MARK: - Professional / Dry Clean
            case "dry_clean_any_solvent_except_trichloroethylene": self = .dryCleanPCE
            case "dry_clean_petrol_only": self = .dryCleanHydrocarbon
            case "wet_clean": self = .professionalWetCleaning
                
                // MARK: - Etichette extra di CreateML da ignorare o gestire
                // Es. "iron" generico, "steam", "wring", "dry_clean_low_heat", ecc.
                // Se non hai un corrispettivo esatto e non sono vitali, restituisci nil.
            default:
                print("⚠️ Etichetta CreateML non mappata: \(createMLLabel)")
                return nil
        }
    }
    
    
    var id: String { rawValue }
    
    var iconName: String? { rawValue }
    
    // Proprietà per raggrupparli nella UI
    var category: LaundryCategory {
        switch self {
            case .machineWashNormal, .machineWashCold, .machineWashWarm, .machineWashHot, .machineWashVeryHot, .machineWashDelicate, .machineWashPermanentPress, .handWash, .doNotMachineWash, .doNotWring:
                return .washing
                
            case .bleach, .bleachNonChlorine, .doNotBleach:
                return .bleaching
                
            case .tumbleDryNormal, .tumbleDryLow, .tumbleDryMedium, .tumbleDryHigh, .tumbleDryNoHeat, .tumbleDryDelicate, .tumbleDryPermanentPress, .doNotTumbleDry, .hangDry, .dripDry, .dryFlat, .dryInShade:
                return .drying
                
            case .ironLow, .ironMedium, .ironHigh, .ironNoSteam, .doNotIron:
                return .ironing
                
            case .dryClean, .dryCleanAnySolvent, .dryCleanHydrocarbon, .dryCleanPCE, .doNotDryClean, .professionalWetCleaning:
                return .professional
        }
    }
    
    var label: String {
        switch self {
                // Washing
            case .machineWashNormal:         return "Machine Wash"
            case .machineWashCold:           return "Cold Wash"
            case .machineWashWarm:           return "Warm Wash"
            case .machineWashHot:            return "Hot Wash"
            case .machineWashVeryHot:        return "Very Hot Wash"
            case .machineWashDelicate:       return "Delicate Cycle"
            case .machineWashPermanentPress: return "Permanent Press"
            case .handWash:                  return "Hand Wash"
            case .doNotMachineWash:          return "Do Not Wash"
            case .doNotWring:                return "Do Not Wring"
                
                // Bleaching
            case .bleach:                    return "Bleach Allowed"
            case .bleachNonChlorine:         return "Non-Chlorine Bleach"
            case .doNotBleach:               return "Do Not Bleach"
                
                // Drying
            case .tumbleDryNormal:           return "Tumble Dry"
            case .tumbleDryLow:              return "Low Heat"
            case .tumbleDryMedium:           return "Medium Heat"
            case .tumbleDryHigh:             return "High Heat"
            case .tumbleDryNoHeat:           return "No Heat"
            case .tumbleDryDelicate:         return "Delicate Dry"
            case .tumbleDryPermanentPress:   return "Perm. Press Dry"
            case .doNotTumbleDry:            return "Do Not Tumble Dry"
            case .hangDry:                   return "Hang Dry"
            case .dripDry:                   return "Drip Dry"
            case .dryFlat:                   return "Dry Flat"
            case .dryInShade:                return "Dry In Shade"
                
                // Ironing
            case .ironLow:                   return "Iron Low"
            case .ironMedium:                return "Iron Medium"
            case .ironHigh:                  return "Iron High"
            case .ironNoSteam:               return "No Steam"
            case .doNotIron:                 return "Do Not Iron"
                
                // Professional
            case .dryClean:                  return "Dry Clean"
            case .dryCleanAnySolvent:        return "Any Solvent"
            case .dryCleanHydrocarbon:       return "Hydrocarbon Only"
            case .dryCleanPCE:               return "PCE Only"
            case .doNotDryClean:             return "Do Not Dry Clean"
            case .professionalWetCleaning:   return "Wet Cleaning"
        }
    }
    
    var title: String { label }
    
    // MARK: - 1. Temperatura Massima di Lavaggio (Vincolo Sicurezza)
    /// Restituisce la temperatura in °C. Restituisce nil se il simbolo non riguarda la temperatura.
    var maxWashingTemperature: Int? {
        switch self {
            case .machineWashCold, .handWash:
                return 30
            case .machineWashWarm, .machineWashPermanentPress:
                return 40 // Permanent Press di solito è max 40°C se non specificato
            case .machineWashHot:
                return 50 // A volte 50 o 60, meglio 50 per sicurezza se "Hot" è generico
            case .machineWashVeryHot:
                return 95
            case .machineWashNormal, .machineWashDelicate:
                // Questi simboli indicano il ciclo, non la temperatura esplicita.
                // Tuttavia, per un algoritmo, serve un default sicuro.
                // Se c'è solo "Normal", si assume 40 solitamente, "Delicate" 30.
                return self == .machineWashDelicate ? 30 : 40
                
            case .doNotMachineWash:
                return 0 // Caso speciale per dire "Niente acqua"
                
            default:
                return nil // Simboli di asciugatura/stiro non hanno temp di lavaggio
        }
    }
    
    // MARK: - 2. Intensità del Ciclo (Azione Meccanica)
    
    var agitationLevel: WashingAgitation {
        switch self {
                // Ciclo Normale
            case .machineWashNormal, .machineWashCold, .machineWashWarm, .machineWashHot, .machineWashVeryHot:
                return .normal
                
                // Ciclo Ridotto (Sintetici)
            case .machineWashPermanentPress:
                return .reduced
                
                // Ciclo Delicato (Lana/Seta)
            case .machineWashDelicate, .handWash, .doNotWring:
                return .gentle
                
            case .doNotMachineWash:
                return .none
                
            default:
                // Se il simbolo non è di lavaggio, non influenza l'agitazione (neutro)
                return .normal
        }
    }
    
    // MARK: - 3. Logica Asciugatrice (Drying)
    /// Se il capo può andare in asciugatrice e a che temperatura
    var canTumbleDry: Bool {
        switch self {
            case .tumbleDryNormal,
                    .tumbleDryLow,
                    .tumbleDryMedium,
                    .tumbleDryHigh,
                    .tumbleDryNoHeat,
                    .tumbleDryDelicate,
                    .tumbleDryPermanentPress:
                return true
            default:
                return false
        }
    }
    
    var dryingTemperatureLimit: Int? {
        switch self {
            case .tumbleDryLow, .tumbleDryDelicate:
                return 60 // Bassa
            case .tumbleDryMedium, .tumbleDryPermanentPress:
                return 70 // Media
            case .tumbleDryHigh, .tumbleDryNormal:
                return 80 // Alta
            case .tumbleDryNoHeat:
                return 20 // Solo aria
            default:
                return nil
        }
    }
    
    // MARK: - 4. Temperatura Stiratura (Ironing)
    /// Restituisce la temperatura massima della piastra del ferro in °C
    var maxIroningTemperature: Int? {
        switch self {
            case .ironLow:
                return 110 // 1 pallino
            case .ironMedium:
                return 150 // 2 pallini
            case .ironHigh:
                return 200 // 3 pallini
            case .ironNoSteam:
                return 110 // Prudenza senza vapore
            case .doNotIron:
                return 0
            default:
                return nil
        }
    }
    
    // MARK: - 5. Metodi di Helper per l'Algoritmo
    
    /// Restituisce TRUE se il simbolo richiede un trattamento "Speciale" (Cesto C)
    var isDelicate: Bool {
        switch self {
            case .machineWashDelicate, .handWash, .doNotWring, .doNotMachineWash,
                    .doNotBleach,
                    .dryFlat, .dripDry, .dryInShade,
                    .ironLow, .doNotIron,
                    .dryClean, .dryCleanAnySolvent, .dryCleanHydrocarbon, .dryCleanPCE, .professionalWetCleaning:
                return true
            default:
                return false
        }
    }
}



enum LaundryBin: String, Codable, CaseIterable, Identifiable {
    case whiteHeavyDuty  = "Whites: Heavy Duty"
    case whiteNormal     = "Whites: Normal"
    case whiteDelicate   = "Whites: Delicate"
    
    
    
    // MARK: - Darks
    case darkNormal      = "Darks: Normal"
    case darkDelicate    = "Darks: Delicate"
    
    
    
    // MARK: - Pastels
    case pastelNormal    = "Pastels: Normal"
    case pastelDelicate  = "Pastels: Delicate"
    
    
    
    // MARK: - Vibrants
    case vibrantNormal   = "Vibrant: Normal"
    case vibrantDelicate = "Vibrant: Delicate"
    
    
    
    // MARK: - Specials
    case denim            = "Denim"
    case activewear       = "Activewear"
    case woolAndCashmere  = "Wool & Cashmere"
    case professionalCare = "Professional Care / Dry Clean"
    
    
    
    var id: String { rawValue }
    
    
    
    var displayName: String {
        switch self {
            case .whiteHeavyDuty:
                "Heavy Whites"
                
            case .whiteNormal:
                "Whites"
                
            case .whiteDelicate:
                "Delicate Whites"
                
            case .darkNormal:
                "Darks"
                
            case .darkDelicate:
                "Delicate Darks"
                
            case .pastelNormal:
                "Pastels"
                
            case .pastelDelicate:
                "Delicate Pastels"
                
            case .vibrantNormal:
                "Vibrants"
                
            case .vibrantDelicate:
                "Delicate Vibrants"
                
            case .denim:
                "Denim"
                
            case .activewear:
                "Activewear"
                
            case .woolAndCashmere:
                "Wool & Cashmere"
                
            case .professionalCare:
                "Dry Clean"
        }
    }
    
    
    
    var description: String {
        switch self {
            case .whiteHeavyDuty:  "Bianchi resistenti ad alte temperature"
            case .whiteNormal:     "Bianchi quotidiani (30°-40°)"
            case .whiteDelicate:   "Bianchi delicati e lingerie"
                
            case .darkNormal:      "Capi scuri quotidiani"
            case .darkDelicate:    "Capi scuri delicati"
                
            case .pastelNormal:    "Colori tenui e pastello"
            case .pastelDelicate:  "Colori tenui delicati"
                
            case .vibrantNormal:   "Colori accesi e scuri"
            case .vibrantDelicate: "Colori accesi delicati"
                
            case .denim:           "Jeans e capi in tela robusta"
            case .activewear:      "Capi tecnici e sportivi"
            case .woolAndCashmere: "Lana, Cashmere e filati pregiati"
            case .professionalCare: "Pelle, camoscio e capi da lavanderia a secco"
        }
    }
    
    var isDelicate: Bool {
        self == .darkDelicate  ||
        self == .pastelDelicate ||
        self == .vibrantDelicate ||
        self == .whiteDelicate
    }
}



enum LaundrySessionStatus: String, Codable, CaseIterable {
    case planned   = "Planed"
    case washing   = "On Washing"
    case drying    = "On Drying"
    case completed = "Complete"
}



enum Program: String, Codable, CaseIterable {
    case standard = "Cotton/Standard"
    case mix      = "Mix"
    case delicate = "Delicate"
    case notWash  = "Not Wash"
}
