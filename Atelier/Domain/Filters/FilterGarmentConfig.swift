//
//  FilterConfig.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 18/02/26.
//

import Foundation

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
