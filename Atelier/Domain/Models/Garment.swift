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
	
    var suggestedLaundryBin: LaundryBin {
        
        if requiresProfessionalCare {
            return .professionalCare
        }
        
        if totalPercentage(of: [.wool, .cashmere]) >= 10.0 {
            return .woolAndCashmere
        }
        
        // 2. Denim: comanda sempre il lavaggio a parte o con capi scuri robusti
        if subCategory == .jeans || totalPercentage(of: [.denim]) >= 50.0 {
            return .denim
        }
        
        // 3. Verifica Delicatezza Combinata (Simboli + Quantità Seta/Delicati)
        let isDelicate = washingSymbols.contains(where: { $0.isDelicate }) ||
                            hasCriticalDelicateFibers ||
                            category == .lingerie ||
                            category == .onePiece
        
        // 4. Analisi Colore (Il nostro fantastico HSB)
        let colorGroup = WashingColorGroup.from(hex: self.color)
        
        // 5. Activewear intelligente: è dominato dai sintetici (es. 70% poly) ED è abbigliamento sportivo?
        let isActivewear = isSyntheticDominant && (style == .sporty || totalPercentage(of: [.fleece]) >= 20.0 || subCategory == .sportsBras)
        
        // 6. Smistamento a Matrice Aggiornato
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
        
    // MARK: - Identikit del Capo basato sui Pesi
    
    /// È un capo a dominanza sintetica? (Oltre il 50%)
    /// I sintetici catturano gli odori e rilasciano microplastiche, spesso richiedono cesti "Activewear" o "Mix" a temperature più basse.
    var isSyntheticDominant: Bool {
        return totalPercentage(of: .synthetic) > 50.0
        // Nota: Assumo che percentual sia 0-100. Se usi 0.0-1.0, metti > 0.5
    }
    
    /// È un capo robusto in cotone/lino? (Tolleranza fino al 15% di altre fibre es. elastan per comodità)
    var isHeavyDutyNatural: Bool {
        let strongNaturals = totalPercentage(of: [.cotton, .linen, .hemp])
        return strongNaturals >= 85.0 // È robusto anche se ha un 5% di Spandex o un 10% di Poliestere
    }
    
    /// Contiene una quantità critica di fibre iper-delicate?
    /// Basta anche un 10% di Cashmere o un 20% di Seta per cambiare le regole del lavaggio.
    var hasCriticalDelicateFibers: Bool {
        let delicatePercentage = totalPercentage(of: [.silk, .wool, .cashmere])
        return delicatePercentage >= 10.0 // Se ha più del 10% di Cashmere, si lava come Cashmere!
    }
    
    var requiresProfessionalCare: Bool {
        totalPercentage(of: [.leather, .suede]) >= 1.0 ||
        washingSymbols.contains(where: { $0 == .doNotMachineWash || $0 == .dryClean || $0 == .dryCleanAnySolvent || $0 == .dryCleanPCE || $0 == .dryCleanHydrocarbon })
    }
    
    /// Calcola la percentuale totale di una specifica categoria di tessuto (es. tutto ciò che è Sintetico)
    func totalPercentage(of category: FabricCategory) -> Double {
        composition
            .filter { $0.fabric.category == category }
            .reduce(0) { total, comp in total + comp.percentual }
    }
    
    /// Calcola la percentuale di tessuti specifici (es. Cotone + Lino)
    func totalPercentage(of fabrics: [GarmentFabric]) -> Double {
        composition
            .filter { fabrics.contains($0.fabric) }
            .reduce(0) { total, comp in total + comp.percentual }
    }
}
