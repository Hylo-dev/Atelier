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
    case leggings    = "Leggings"
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
}
