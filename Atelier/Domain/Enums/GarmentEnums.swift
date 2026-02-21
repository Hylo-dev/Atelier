//
//  GarmentEnums.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 15/02/26.
//

import Foundation

enum GarmentCategory: String, Codable, CaseIterable, Identifiable {
    case top
    case bottom
    case outerwear
    case onePiece
    case footwear
    case accessory
	case lingerie
	case other
    
    var id: String { rawValue }
    
    var label: String {
        return switch self {
            case .top      : "Upper Body"
            case .bottom   : "Bottom"
            case .outerwear: "Outerwear"
            case .onePiece : "One Piece"
            case .footwear : "Footwear"
            case .accessory: "Accessory"
		    case .lingerie : "Lingerie"
            case .other    : "Other"
        }
    }
    
    var subCategory: [GarmentSubCategory] {
        return switch self {
            case .top: [
                .tshirts,
                .shirts,
                .blouses,
                .sweaters,
                .hoodies,
                .sweatshirt,
                .top,
                .tankTops,
                .bodysuits
            ]
                
            case .bottom: [
                .jeans,
                .trousers,
                .shorts,
                .skirts,
                .leggings,
                .sweatpants
            ]
                
            case .outerwear: [
                .coats,
                .jackets,
                .blazers,
                .pufferJackets,
                .rainwear
            ]
                
            case .onePiece: [
                .dresses,
                .jumpsuits
            ]
                
            case .footwear: [
                .sneakers,
                .boots,
                .loafers,
                .heels,
                .sandals,
                .flats,
                .slippers
            ]
                
            case .accessory: [
                .bags,
                .belts,
                .hats,
                .scarves,
                .jewelry,
                .eyewear,
                .watches
            ]
			
			case .lingerie: [
				.bras,
				.sportsBras,
				.bralettes,
				.panties,
				.thongs,
				.boxerShorts,
				.boxerBriefs,
				.briefs,
				.socks,
				.tights,
				.stockings,
				.pajamas,
				.nightgowns,
				.robes,
				.bodysuitsLingerie,
				.shapewear
			]
			
			case .other: [ .none ]
		}
    }
}

enum GarmentSubCategory: String, Codable, CaseIterable, Identifiable {
    
    // MARK: - Top Garments
    case tshirts    = "T-Shirts"
    case shirts     = "Shirts"
    case blouses    = "Blouses"
    case sweaters   = "Sweaters"
    case hoodies    = "Hoodies"
    case sweatshirt = "Sweatshirt"
    case top        = "Top"
    case tankTops   = "Tank Tops"
    case bodysuits  = "Bodysuits"
    
    
    // MARK: - Bottom Garments
    case jeans      = "Jeans"
    case trousers   = "Trousers"
    case shorts     = "Shorts"
    case skirts     = "Skirts"
    case leggings   = "Leggings"
    case sweatpants = "Sweatpants"
    
    
    // MARK: - Outerwear Garments
    case coats          = "Coats"
    case jackets        = "Jackets"
    case blazers        = "Blazers"
    case pufferJackets  = "Puffer Jackets"
    case rainwear       = "Rainwear"
    
    
    // MARK: - One Piece Garments
    case dresses    = "Dresses"
    case jumpsuits  = "Jumpsuits"
    
    
    // MARK: - Footwear Garments
    case sneakers   = "Sneakers"
    case boots      = "Boots"
    case loafers    = "Loafers"
    case heels      = "Heels"
    case sandals    = "Sandals"
    case flats      = "Flats"
    case slippers   = "Slippers"
    
    
    // MARK: - Accessory Garments
    case bags       = "Bags"
    case belts      = "Belts"
    case hats       = "Hats"
    case scarves    = "Scarves"
    case jewelry    = "Jewelry"
    case eyewear    = "Eyewear"
    case watches    = "Watches"
	
	// MARK: - Underwear & Lingerie (Specifici)
	case bras           = "Bras"
	case sportsBras     = "Sports Bras"
	case bralettes      = "Bralettes"
	case panties        = "Panties"
	case thongs         = "Thongs & Tangas"
	
	// Men's Underwear
	case boxerShorts    = "Boxer Shorts"
	case boxerBriefs    = "Boxer Briefs"
	case briefs         = "Briefs"
	
	// Legwear
	case socks          = "Socks"
	case tights         = "Tights / Collant"
	case stockings      = "Stockings"
	
	// Nightwear & Lounge
	case pajamas        = "Pajamas"
	case nightgowns     = "Nightgowns"
	case robes          = "Robes & Dressing Gowns"
	
	// Functional/Other
	case bodysuitsLingerie = "Lingerie Bodysuits"
	case shapewear      = "Shapewear"
    
    case none       = "None"
    
    var id: String { rawValue }
}

enum GarmentState: String, Codable, CaseIterable, Identifiable {
    
    case available   = "Available"
    case toWash      = "To wash"
    case atLaundry   = "At laundry"
    case onLoan      = "On loan"
    case underRepair = "Under repair"
    case drying      = "Drying"
    
    var id: String { rawValue }
    
    func readyToWash() -> Bool {
        return self != .drying && self != .onLoan && self != .underRepair
    }
    
    func readyToLent() -> Bool {
        return self != .underRepair
    }
    
}

enum Season: String, Codable, CaseIterable, Identifiable {
    case summer     = "Summer"
    case winter     = "Winter"
    case spring     = "Spring"
    case seasonLess = "SeasonLess"
    
    var id: String { rawValue }
}

enum GarmentStyle: String, Codable, CaseIterable, Identifiable {
    case casual   = "Casual"
    case formal   = "Formal"
    case sporty   = "Sporty"
    case elegant  = "Elegant"
    case business = "Business"
    
    var id: String { rawValue }
}

struct GarmentComposition: Identifiable, Codable {
    var id        : UUID = UUID()
    var fabric    : GarmentFabric
    var percentual: Double
}

enum FabricCategory: String, CaseIterable, Identifiable {
    case natural   = "Natural Fibers"
    case synthetic = "Synthetic & Semis"
    case mix       = "Mixed & Others"
    
    var id: String { rawValue }
}

enum GarmentFabric: String, Codable, SelectableItem {
    
    // MARK: - Natural
    case cotton   = "Cotton"
    case wool     = "Wool"
    case silk     = "Silk"
    case linen    = "Linen"
    case hemp     = "Hemp"
    case leather  = "Leather"
    case suede    = "Suede"
    case cashmere = "Cashmere"
    
    // MARK: - Synthetic/Semi-Synthetic
    case polyester = "Polyester"
    case nylon     = "Nylon"
    case spandex   = "Spandex"
    case viscose   = "Viscose"
    case acrylic   = "Acrylic"
    
    // MARK: - Mix
    case denim  = "Denim"
    case velvet = "Velvet"
    case fleece = "Fleece"
    case jersey = "Jersey"
    
    var id: String { rawValue }
    
    var iconName: String? { nil }
    
    var title: String { rawValue }
    
    var category: FabricCategory {
        switch self {
            case .cotton, .wool, .silk, .linen, .hemp, .leather, .suede, .cashmere:
                return .natural
            case .polyester, .nylon, .spandex, .viscose, .acrylic:
                return .synthetic
            case .denim, .velvet, .fleece, .jersey:
                return .mix
        }
    }
}

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
	case heavyDuty = "White & Hot"
	case daily     = "Daily Dark"
	case delicate  = "Delicate"
	
	var id: String { rawValue }
	
	var description: String {
		switch self {
		case .heavyDuty: return "Bianchi, asciugamani, intimo cotone"
		case .daily: return "Jeans, t-shirt colorate, sintetici"
		case .delicate: return "Lana, seta, tecnici, ricami"
		}
	}
}

// Serve per il "Vincolo 1: Colore"
enum WashingColorGroup: String, Codable, CaseIterable {
	case whites      = "Whites"
	case darks       = "Darks"
	case lights      = "Lights/Colors"
	
	/// Restituisce la categoria di lavaggio basata sul codice Hex
	static func classify(_ hex: String) -> WashingColorGroup {
		let rgb = hexToRGB(hex)
		let (_, s, b) = rgbToHSB(r: rgb.r, g: rgb.g, b: rgb.b)
		
		// --- LOGICA DI CLASSIFICAZIONE ---
		
		// 1. Categoria BIANCHI (Whites)
		// Alta luminosità (> 85%) e bassissima saturazione (< 15%)
		// Esempio: Bianco puro, panna, grigio chiarissimo
		if b > 0.85 && s < 0.15 {
			return .whites
		}
		
		// 2. Categoria SCURI (Darks)
		// Bassa luminosità (< 30%), indipendentemente dalla saturazione
		// Esempio: Nero, Blu Notte, Marrone scuro, Bordeaux profondo
		if b < 0.30 {
			return .darks
		}
		
		// 3. Categoria COLORATI / MEDI (Lights/Colors)
		// Tutto il resto: Colori accesi, pastelli, grigi medi
		return .lights
	}
	
	// MARK: - Helpers Matematici
	
	/// Converte stringa Hex (es. "#FF0000" o "FF0000") in valori R, G, B da 0 a 1
	static func hexToRGB(_ hex: String) -> (r: CGFloat, g: CGFloat, b: CGFloat) {
		var cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
		
		if (cString.hasPrefix("#")) {
			cString.remove(at: cString.startIndex)
		}
		
		if ((cString.count) != 6) {
			return (0.5, 0.5, 0.5) // Fallback grigio se codice errato
		}
		
		var rgbValue: UInt64 = 0
		Scanner(string: cString).scanHexInt64(&rgbValue)
		
		return (
			CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
			CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
			CGFloat(rgbValue & 0x0000FF) / 255.0
		)
	}
	
	/// Converte RGB in HSB (Hue, Saturation, Brightness)
	/// H: 0-360, S: 0-1, B: 0-1
	static func rgbToHSB(r: CGFloat, g: CGFloat, b: CGFloat) -> (h: CGFloat, s: CGFloat, b: CGFloat) {
		let minV = min(r, g, b)
		let maxV = max(r, g, b)
		let delta = maxV - minV
		
		var hue: CGFloat = 0
		if delta != 0 {
			if maxV == r {
				hue = (g - b) / delta
			} else if maxV == g {
				hue = 2 + (b - r) / delta
			} else {
				hue = 4 + (r - g) / delta
			}
			hue *= 60
			if hue < 0 { hue += 360 }
		}
		
		let saturation = maxV == 0 ? 0 : (delta / maxV)
		let brightness = maxV
		
		return (hue, saturation, brightness)
	}
	
	static func from(hex: String) -> WashingColorGroup {
		return self.classify(hex)
	}
}

enum WashingAgitation: String, Sendable, Equatable {
	case normal
	case reduced     // "Synthetics" / "Permanent Press"
	case gentle      // "Delicates" / "Wool"
	case none        // Non lavare / Non centrifugare
}
