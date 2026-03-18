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
    
    var wearLimit: Int {
        switch self {
                
            case .tshirts, .tankTops, .bodysuits, .sweatpants,
                    .bras, .bralettes, .sportsBras, .panties, .thongs, .boxerShorts,
                    .boxerBriefs, .briefs, .socks, .tights, .stockings,
                    .bodysuitsLingerie, .shapewear:
                return 1
                
            case .shirts, .blouses, .dresses, .jumpsuits, .pajamas, .nightgowns:
                return 2
                
            case .trousers, .shorts, .skirts, .leggings, .sweaters, .hoodies, .sweatshirt, .top:
                return 3
                
            case .jeans:
                return 5
                
            case .coats, .jackets, .blazers, .pufferJackets, .rainwear, .robes:
                return 10
                
            case .sneakers, .boots, .loafers, .heels, .sandals, .flats, .slippers,
                    .bags, .belts, .hats, .scarves, .jewelry, .eyewear, .watches, .none:
                return -1
        }
    }
}



enum GarmentState: String, Codable, CaseIterable, Identifiable {
    
    case available   = "Available"
    case toWash      = "To wash"
    case washing     = "Washing"
    case atLaundry   = "At laundry"
    case onLoan      = "On loan"
    case underRepair = "Under repair"
    case drying      = "Drying"
    
    var id: String { rawValue }
    
    var readyToWash: Bool {
        self != .drying && self != .onLoan && self != .underRepair
    }
    
    var readyToLent: Bool {
        self != .underRepair
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
                .natural
                
            case .polyester, .nylon, .spandex, .viscose, .acrylic:
                .synthetic
                
            case .denim, .velvet, .fleece, .jersey:
                .mix
        }
    }
}
