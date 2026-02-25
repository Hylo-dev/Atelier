//
//  FilterConfig.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 18/02/26.
//

import Foundation

struct FilterGarmentConfig: Equatable {
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
    
    mutating func reset() {
        self.selectedBrand       = nil
        self.selectedSubCategory = nil
        self.selectedSeason      = nil
        self.selectedStyle       = nil
        self.selectedColor       = nil
        self.selectedState       = nil
        self.onlyClean           = false
    }
    
    static func filterGarments(
        allGarments: [Garment],
        config     : Self
    ) -> [Garment] {
        
        return allGarments.filter { garment in

            if let brandToFind = config.selectedBrand,
                    garment.brand == nil || !brandToFind.contains(garment.brand!) {
                return false
            }
            
            if let subCategoryToFind = config.selectedSubCategory,
                   !subCategoryToFind.contains(garment.subCategory) {
                return false
            }
            
            if let seasonToFind = config.selectedSeason,
                   !seasonToFind.contains(garment.season) {
                return false
            }
            
            if let styleToFind = config.selectedStyle,
                   !styleToFind.contains(garment.style) {
                return false
            }
            
            if let stateToFind = config.selectedState,
                   !stateToFind.contains(garment.state) {
                return false
            }
            
            if config.onlyClean && garment.state != .available {
                return false
            }
            
            return true
        }
    }
}

struct FilterOutfitConfig: Equatable {
    var recentWorn     : Bool               = false
    var selectedStyle      : Set<GarmentStyle>? = nil
    var onlyClean          : Bool               = false
    
    var isFiltering: Bool {
        self.recentWorn        ||
        self.selectedStyle  != nil ||
        self.onlyClean
    }
    
    mutating func reset() {
        self.recentWorn = false
        self.selectedStyle  = nil
        self.onlyClean      = false
    }
    
    static func filterOutfits(
        allOutfits: [Outfit],
        config    : Self
    ) -> [Outfit] {
        
        var outfits = allOutfits.filter { outfit in
            
            if let styleToFind = config.selectedStyle,
               !styleToFind.contains(outfit.style) {
                return false
            }
            
            if config.onlyClean && !outfit.isReadyToWear {
                return false
            }
            
            return true
        }
        
        if config.recentWorn {
            outfits.sort {
                let date0 = $0.lastWornDate ?? Date.distantPast
                let date1 = $1.lastWornDate ?? Date.distantPast
                
                return date0 > date1
            }
        }
        
        
        return outfits
    }
}
