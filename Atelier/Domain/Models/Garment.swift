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
    
    // MARK: Handler Washing
    var isBinAssigned: Bool

    
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
        isBinAssigned : Bool = false,
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
        self.isBinAssigned  = isBinAssigned
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
        
        // 1. Priorità Assoluta: Lana e Cashmere (Cesto Speciale)
        if composition.contains(where: { $0.fabric == .wool || $0.fabric == .cashmere }) {
            return .woolAndCashmere
        }
        
        // 2. Priorità Alta: Denim (Per evitare che stingano su altri tessuti)
        if subCategory == .jeans || composition.contains(where: { $0.fabric == .denim }) {
            return .denim
        }
        
        // 3. Analisi del Livello di Delicatezza
        let isDelicate = washingSymbols.contains(where: { $0.isDelicate }) ||
        composition.contains(where: { $0.fabric == .silk }) ||
        category == .lingerie ||
        category == .onePiece
        
        // 4. Analisi del Colore
        let colorGroup = WashingColorGroup.from(hex: self.color)
        
        // 5. Verifica Tessuti Specifici
        let isResistantCotton = composition.allSatisfy { $0.fabric == .cotton || $0.fabric == .linen || $0.fabric == .hemp }
        let isActivewear = composition.contains(where: { $0.fabric == .spandex || $0.fabric == .nylon }) && subCategory == .sportsBras
        
        // 6. Smistamento a Matrice (Colore + Trattamento)
        switch colorGroup {
            case .whites:
                if isDelicate { return .whiteDelicate }
                if isResistantCotton { return .whiteHeavyDuty }
                return .whiteNormal
                
            case .darks:
                if isDelicate { return .darkDelicate }

                return .darkNormal
                
            case .lights:
                if isDelicate { return .colorDelicate }
                if isActivewear { return .activewear }

                return .colorNormal
        }
    }
	
	var isDelicatePriority: Bool {
        suggestedLaundryBin.isDelicate
	}
    
    var requiresWashing: Bool {
        wearCount >= subCategory.wearLimit
    }
	
    var daysSinceLastWash: Int {
        guard let lastWashingDate = lastWashingDate else { return 999 }
        return Calendar.current.dateComponents([.day], from: lastWashingDate, to: .now).day ?? 0
    }
    
    var hasReachedWashingLimits: Bool {
        let wearLimitReached = wearCount >= subCategory.wearLimit
        let timeLimitReached = (daysSinceLastWash >= 30) && (wearCount > 0)
        
        return wearLimitReached || timeLimitReached
    }
    
    var isReadyToWash: Bool {
        return state.readyToWash && hasReachedWashingLimits
    }
}
