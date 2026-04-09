//
//  FilterOutfitConfig.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 07/04/2026.
//

import Foundation


struct FilterOutfitConfig: @MainActor FilterProtocol {
    typealias T = Outfit
    
    var recentWorn       : Bool
    var selectedOccasions: Set<GarmentStyle>?
    var selectedSeasons  : Set<Season>?
    var selectedTone     : Tone
    var maxPrice         : Double
    var onlyClean        : Bool
    var onlyFavorite     : Bool
    
    var isFiltering: Bool {
        recentWorn                 ||
        selectedOccasions != nil   ||
        selectedSeasons   != nil   ||
        selectedTone      != .none ||
        maxPrice          != 0     ||
        onlyClean                  ||
        onlyFavorite
    }
    
    init() {
        self.recentWorn        = false
        self.selectedOccasions = nil
        self.selectedSeasons   = nil
        self.selectedTone      = .none
        self.maxPrice          = 0
        self.onlyClean         = false
        self.onlyFavorite      = false
    }
        
    mutating func reset() {
        recentWorn        = false
        selectedOccasions = nil
        selectedSeasons   = nil
        selectedTone      = .none
        maxPrice          = 0
        onlyClean         = false
        onlyFavorite      = false
    }
    
    func generatePredicate() -> Predicate<Outfit> {
        guard isFiltering else {
            return #Predicate { _ in true }
        }
                
        let isOnlyClean = onlyClean
        let isOnlyFavorite = onlyFavorite
        let limitPrice = maxPrice
        let selectedToneRaw = selectedTone.rawValue
        let isToneNone = selectedTone == .none
        
        // Trasformiamo i Set in Array per il confronto
//        let occasionsList = (selectedOccasions ?? []).map { $0.rawValue }
        let seasonsList = (selectedSeasons ?? []).map { $0.rawValue }
        
        let noSeasonFilter = seasonsList.isEmpty
        
        
        return #Predicate<Outfit> { outfit in
            (!isOnlyClean || outfit.isReadyToWearRaw) &&
            (!isOnlyFavorite || outfit.isFavorite) &&
            (isToneNone || outfit.toneRaw == selectedToneRaw) &&
            (limitPrice <= 0 || outfit.totalValue <= limitPrice) &&
            (noSeasonFilter || seasonsList.contains(outfit.seasonRaw))
        }
    }
    
    
    static func == (
        lhs: FilterOutfitConfig,
        rhs: FilterOutfitConfig
    ) -> Bool {
        lhs.recentWorn        == rhs.recentWorn &&
        lhs.selectedOccasions == rhs.selectedOccasions &&
        lhs.selectedSeasons   == rhs.selectedSeasons &&
        lhs.selectedTone      == rhs.selectedTone &&
        lhs.maxPrice          == rhs.maxPrice &&
        lhs.onlyClean         == rhs.onlyClean &&
        lhs.onlyFavorite      == rhs.onlyFavorite
    }
}
