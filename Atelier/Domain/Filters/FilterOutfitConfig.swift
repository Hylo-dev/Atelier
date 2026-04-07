//
//  FilterOutfitConfig.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 07/04/2026.
//

import Foundation


struct FilterOutfitConfig: FilterProtocol {
    typealias T = Outfit
    
    var recentWorn       : Bool               = false
    var selectedOccasions: Set<GarmentStyle>? = nil
    var selectedSeasons  : Set<Season>?       = nil
    var selectedTone     : Tone               = .none
    var maxPrice         : Double             = 0
    var onlyClean        : Bool               = false
    var onlyFavorite     : Bool               = false
    
    var isFiltering: Bool {
        recentWorn                 ||
        selectedOccasions != nil   ||
        selectedSeasons   != nil   ||
        selectedTone      != .none ||
        maxPrice          != 0     ||
        onlyClean                  ||
        onlyFavorite
    }
    
    nonisolated static func == (
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
    
    mutating func reset() {
        recentWorn        = false
        selectedOccasions = nil
        selectedSeasons   = nil
        selectedTone      = .none
        maxPrice          = 0
        onlyClean         = false
        onlyFavorite      = false
    }
    
    func filter(_ items: [Outfit]) -> [Outfit] {
        
        guard isFiltering else {
            return items
        }
        
        var outfits = items.filter { outfit in
            
            if onlyClean && !outfit.isReadyToWear {
                return false
            }
            
            if onlyFavorite && !outfit.isFavorite {
                return false
            }
            
            if selectedTone != .none &&
                selectedTone != outfit.tone {
                return false
            }
            
            if let selectedOccasions = selectedOccasions, !selectedOccasions.isEmpty {
                
                let outfitOccasionsSet = Set(outfit.occasion)
                if outfitOccasionsSet.isDisjoint(
                    with: selectedOccasions
                ) {
                    return false
                }
            }
            
            if let seasonsToFind = selectedSeasons,
                !seasonsToFind.isEmpty {
                
                if !seasonsToFind.contains(outfit.season) {
                    return false
                }
            }
                        
            if maxPrice > 0 && outfit.totalValue > maxPrice {
                return false
            }
            
            return true
        }
        
        if recentWorn {
            outfits.sort {
                let date0 = $0.lastWornDate ?? Date.distantPast
                let date1 = $1.lastWornDate ?? Date.distantPast
                
                return date0 > date1
            }
        }
        
        return outfits
    }
}
