//
//  Garmen.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 15/02/26.
//

import SwiftData
import Foundation

@Model
final class Garment {
    @Attribute(.unique) var id: UUID
    
    // MARK: - Object Description
    var name        : String
    var brand       : String?
    var color       : String
    var composition : [GarmentComposition]
    var category    : GarmentCategory
    var subCategory : GarmentSubCategory
    var season      : Season
    var style       : GarmentStyle
    var purchaseDate: Date
    var state       : GarmentState

    
    // MARK: - Washing Info
    var washingSymbols : [LaundrySymbol]
    var lastWashingDate: Date?
    var wearCount      : Int
    
        
    // MARK: - Graphic
    var imagePath  : String? // Path to image 2D
    var model3DPath: String? // Path to model 3D
    
    @Relationship(inverse: \Outfit.garments)
    var outfits: [Outfit]
	
	@Relationship(inverse: \LaundrySession.garments)
	var activeLaundrySession: LaundrySession?
    
    init(
        id            : UUID = UUID(),
        name          : String,
        brand         : String? = nil,
        color         : String,
        composition   : [GarmentComposition],
        category      : GarmentCategory,
        subCategory   : GarmentSubCategory,
        season        : Season,
        style         : GarmentStyle,
        purchaseDate  : Date = .now,
        washingSymbols: [LaundrySymbol] = [],
        imagePath     : String? = nil,
        model3DPath   : String? = nil
    ) {
        self.id             = id
        self.name           = name
        self.brand          = brand
        self.color          = color
        self.composition    = composition
        self.category       = category
        self.subCategory    = subCategory
        self.season         = season
        self.style          = style
        self.purchaseDate   = purchaseDate
        self.state          = .available
        
        self.washingSymbols = washingSymbols
        self.wearCount      = 0
        
        self.imagePath      = imagePath
        self.model3DPath    = model3DPath
        
        self.outfits        = []
		self.activeLaundrySession = .none
    }
	
	// Determina in che Cesto (A, B, C) dovrebbe andare
	var suggestedLaundryBin: LaundryBin {
		
		// 1. Priorità Assoluta: Delicati (Cesto C)
		if category == .onePiece ||
			composition.contains(where: { $0.fabric == .silk || $0.fabric == .wool || $0.fabric == .cashmere }) ||
			washingSymbols.contains(where: { $0.isDelicate }) {
			return .delicate
		}
		
		// 2. Analisi Colore tramite HEX
		let colorGroup = WashingColorGroup.from(hex: self.color)
		
		// 3. Verifica Tessuto
		let isResistantCotton = composition.allSatisfy { $0.fabric == .cotton || $0.fabric == .linen || $0.fabric == .hemp }
		
		// LOGICA DECISIONALE
		
		// Cesto A (Bianchi & Resistenti)
		// Solo se è "White" matematicamente E resistente
		if colorGroup == .whites && isResistantCotton {
			return .heavyDuty
		}
		
		// Cesto B (Scuri & Quotidiani)
		// Tutto il resto (Scuri, Colorati, Sintetici non delicati)
		return .daily
	}
	
	// Helper per capire se il capo comanda il lavaggio delicato
	var isDelicatePriority: Bool {
		return suggestedLaundryBin == .delicate
	}
	
}
