//
//  FilterConfig.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 18/02/26.
//

import Foundation
import SwiftData

protocol FilterProtocol<T>: Equatable, Sendable {
    associatedtype T: PersistentModel
    var isFiltering: Bool { get }
    
    mutating func reset()
    func filter(_ items: [T]) -> [T]
}

struct FilterGarmentConfig: FilterProtocol {
    typealias T = Garment
        
    var selectedBrand      : Set<String>?             = nil
    var selectedSubCategory: Set<GarmentSubCategory>? = nil
    var selectedSeason     : Set<Season>?             = nil
    var selectedStyle      : Set<GarmentStyle>?       = nil
    var selectedColor      : Set<String>?             = nil
    var selectedState      : Set<GarmentState>?       = nil
    var onlyClean          : Bool                     = false
    
    var isFiltering: Bool {
        return self.selectedBrand       != nil ||
               self.selectedSubCategory != nil ||
               self.selectedSeason      != nil ||
               self.selectedStyle       != nil ||
               self.selectedColor       != nil ||
               self.selectedState       != nil ||
               self.onlyClean
    }
    
    nonisolated static func == (
        lhs: FilterGarmentConfig,
        rhs: FilterGarmentConfig
    ) -> Bool {
        lhs.selectedBrand       == rhs.selectedBrand &&
        lhs.selectedSubCategory == rhs.selectedSubCategory &&
        lhs.selectedSeason      == rhs.selectedSeason &&
        lhs.selectedStyle       == rhs.selectedStyle &&
        lhs.selectedColor       == rhs.selectedColor &&
        lhs.selectedState       == rhs.selectedState &&
        lhs.onlyClean           == rhs.onlyClean
    }
    
    mutating func reset() {
        self.selectedBrand       = nil
        self.selectedSubCategory = nil
        self.selectedSeason      = nil
        self.selectedStyle       = nil
        self.selectedColor       = nil
        self.selectedState       = nil
        self.onlyClean           = false
    }
    
    func filter(_ items: [Garment]) -> [Garment] {
        
        guard isFiltering else {
            return items
        }
        
        return items.filter { garment in
            
            if onlyClean && garment.state != .available {
                return false
            }
            
            if let stateToFind = selectedState,
               !stateToFind.contains(garment.state) {
                return false
            }
            
            if let seasonToFind = selectedSeason,
               !seasonToFind.contains(garment.season) {
                return false
            }
            
            if let styleToFind = selectedStyle,
               !styleToFind.contains(garment.style) {
                return false
            }
            
            if let subCategoryToFind = selectedSubCategory,
               !subCategoryToFind.contains(garment.subCategory) {
                return false
            }
            
            if let brandToFind = selectedBrand {
                guard let garmentBrand = garment.brand, brandToFind.contains(garmentBrand) else {
                    return false
                }
            }
            
            return true
        }
    }
}

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
            
            if selectedTone != outfit.tone {
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
