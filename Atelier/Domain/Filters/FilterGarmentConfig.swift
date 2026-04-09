//
//  FilterConfig.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 18/02/26.
//

import Foundation

//
//  FilterConfig.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 18/02/26.
//

import Foundation

struct FilterGarmentConfig { // : FilterProtocol TODO: Set this when modified all filters
    
    var selectedBrand      : Set<String>?             = nil
    var selectedSubCategory: Set<GarmentSubCategory>? = nil
    var selectedSeason     : Set<Season>?             = nil
    var selectedStyle      : Set<GarmentStyle>?       = nil
    var selectedColor      : Set<String>?             = nil
    var selectedCondition  : Set<GarmentState>?       = nil
    var onlyClean          : Bool                     = false
    
    var isFiltering: Bool {
        return self.selectedBrand != nil ||
        self.selectedSubCategory  != nil ||
        self.selectedSeason       != nil ||
        self.selectedStyle        != nil ||
        self.selectedColor        != nil ||
        self.selectedCondition    != nil ||
        self.onlyClean
    }
    
    var predicate: Predicate<Garment> {
        let availableRaw = GarmentState.available.rawValue
        
        let selectedStates = (selectedCondition ?? []).map { $0.rawValue }
        let selectedSeasons = (selectedSeason ?? []).map { $0.rawValue }
        let selectedStyles = (selectedStyle ?? []).map {
            $0.rawValue
        }
        let selectedSubCategories = (selectedSubCategory ?? []).map {
            $0.rawValue
        }
//        let selectedBrands = Array(selectedBrand ?? [])
        
        let filterByState  = selectedStates.isEmpty
        let filterBySeason = selectedSeasons.isEmpty
        let filterByStyle  = selectedStyles.isEmpty
        let filterBySubCategories = selectedSubCategories.isEmpty
//        let filterByBrands = selectedBrands.isEmpty

        
        return #Predicate<Garment> { garment in
            (!onlyClean || garment.stateRaw == availableRaw) &&
            (filterByState || selectedStates.contains(garment.stateRaw)) &&
            (filterBySeason || selectedSeasons.contains(garment.seasonRaw)) &&
            (filterByStyle || selectedStyles.contains(garment.styleRaw)) &&
            (filterBySubCategories || selectedSubCategories.contains(garment.subCategoryRaw))
//            &&
//            (filterByBrands || (garment.brand != nil && selectedBrands.contains(garment.brand ?? "")))
        }
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
        lhs.selectedCondition       == rhs.selectedCondition &&
        lhs.onlyClean           == rhs.onlyClean
    }
    
    mutating func reset() {
        self.selectedBrand       = nil
        self.selectedSubCategory = nil
        self.selectedSeason      = nil
        self.selectedStyle       = nil
        self.selectedColor       = nil
        self.selectedCondition   = nil
        self.onlyClean           = false
    }
}
