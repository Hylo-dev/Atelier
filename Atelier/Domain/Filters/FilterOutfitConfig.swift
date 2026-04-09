//
//  FilterOutfitConfig.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 07/04/2026.
//

import Foundation


final class FilterOutfitConfig: @MainActor FilterProtocol {
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
        
    func reset() {
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
                
        let isOnlyClean   : Bool   = onlyClean
        let isOnlyFavorite: Bool   = onlyFavorite
        let isToneNone    : Bool   = selectedTone == Tone.none
        let limitPrice    : Double = maxPrice
        
        
        let selectedOccasionsList: [String] = (selectedOccasions ?? []).map {
            $0.rawValue
        }
        
        let selectedSeasonsList: [String] = (selectedSeasons ?? []).map {
            $0.rawValue
        }
        
        
        let filterByOccasions = selectedOccasionsList.isEmpty
        let filterBySeasons = selectedSeasonsList.isEmpty
        let filterByTone: String = selectedTone.rawValue
        
        
        let cleanFilter = #Predicate<Outfit> { outfit in
            !isOnlyClean || outfit.isReadyToWearRaw
        }
        
        let favoriteFilter = #Predicate<Outfit> { outfit in
            !isOnlyFavorite || outfit.isFavorite
        }
        
        let toneFilter = #Predicate<Outfit> { outfit in
            !isToneNone || outfit.toneRaw == filterByTone
        }
        
        let priceFilter = #Predicate<Outfit> { outfit in
            limitPrice <= 0 || outfit.totalValue <= limitPrice
        }
        
        let seasonFilter = #Predicate<Outfit> { outfit in
            filterBySeasons || selectedSeasonsList.contains(outfit.seasonRaw)
        }
        
        let occasionFilter = #Predicate<Outfit> { outfit in
            filterByOccasions || outfit.occasionsRaw.contains(selectedOccasionsList)
        }
        
        return #Predicate<Outfit> { outfit in
            cleanFilter.evaluate(outfit) &&
            favoriteFilter.evaluate(outfit) &&
            toneFilter.evaluate(outfit) &&
            priceFilter.evaluate(outfit) &&
            seasonFilter.evaluate(outfit) &&
            occasionFilter.evaluate(outfit)
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
