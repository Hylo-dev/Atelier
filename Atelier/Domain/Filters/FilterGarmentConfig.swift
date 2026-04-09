//
//  FilterConfig.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 18/02/26.
//

import Foundation

struct FilterGarmentConfig: @MainActor FilterProtocol {
    typealias T = Garment
    
    var selectedBrand      : Set<String>?             = nil
    var selectedSubCategory: Set<GarmentSubCategory>? = nil
    var selectedSeason     : Set<Season>?             = nil
    var selectedStyle      : Set<GarmentStyle>?       = nil
    var selectedColor      : Set<String>?             = nil
    var selectedCondition  : Set<GarmentState>?       = nil
    var onlyClean          : Bool                     = false
    
    var isFiltering: Bool {
        selectedBrand != nil ||
        selectedSubCategory  != nil ||
        selectedSeason       != nil ||
        selectedStyle        != nil ||
        selectedColor        != nil ||
        selectedCondition    != nil ||
        onlyClean
    }
    
    init() {
        self.selectedBrand       = nil
        self.selectedSubCategory = nil
        self.selectedSeason      = nil
        self.selectedStyle       = nil
        self.selectedColor       = nil
        self.selectedCondition   = nil
        self.onlyClean           = false
    }
    
    mutating func reset() {
        selectedBrand       = nil
        selectedSubCategory = nil
        selectedSeason      = nil
        selectedStyle       = nil
        selectedColor       = nil
        selectedCondition   = nil
        onlyClean           = false
    }
    
    func generatePredicate() -> Predicate<Garment> {
        guard isFiltering else {
            return #Predicate { _ in true }
        }
        
        let availableRaw = GarmentState.available.rawValue
        
        let selectedStates        = Array(selectedCondition ?? []).map { $0.rawValue }
        let selectedSeasons       = Array(selectedSeason ?? []).map { $0.rawValue }
        let selectedStyles        = Array(selectedStyle ?? []).map { $0.rawValue }
        let selectedSubCategories = Array(selectedSubCategory ?? []).map { $0.rawValue }
        let selectedBrands: [String?] = Array(selectedBrand ?? [])
        
        let filterByState         = selectedStates.isEmpty
        let filterBySeason        = selectedSeasons.isEmpty
        let filterByStyle         = selectedStyles.isEmpty
        let filterBySubCategories = selectedSubCategories.isEmpty
        let filterByBrands        = selectedBrands.isEmpty
        let isOnlyClean           = onlyClean
        
        let cleaned = #Predicate<Garment> { garment in
            !isOnlyClean || garment.stateRaw == availableRaw
        }
        let stateFinded = #Predicate<Garment> { garment in
            filterByState || selectedStates.contains(garment.stateRaw)
        }
        let seasonFinded = #Predicate<Garment> { garment in
            filterBySeason || selectedSeasons.contains(garment.seasonRaw)
        }
        let styleFinded = #Predicate<Garment> { garment in
            filterByStyle || selectedStyles.contains(garment.styleRaw)
        }
        let subCategoryFinded = #Predicate<Garment> { garment in
            filterBySubCategories || selectedSubCategories.contains(garment.subCategoryRaw)
        }
        let brandFinded = #Predicate<Garment> { garment in
            filterByBrands || selectedBrands.contains(garment.brand)
        }
        
        return #Predicate<Garment> {
            cleaned.evaluate($0) &&
            stateFinded.evaluate($0) &&
            seasonFinded.evaluate($0) &&
            styleFinded.evaluate($0) &&
            subCategoryFinded.evaluate($0) &&
            brandFinded.evaluate($0)
        }
    }
    
    static func == (lhs: FilterGarmentConfig, rhs: FilterGarmentConfig) -> Bool {
        lhs.selectedBrand       == rhs.selectedBrand &&
        lhs.selectedSubCategory == rhs.selectedSubCategory &&
        lhs.selectedSeason      == rhs.selectedSeason &&
        lhs.selectedStyle       == rhs.selectedStyle &&
        lhs.selectedColor       == rhs.selectedColor &&
        lhs.selectedCondition   == rhs.selectedCondition &&
        lhs.onlyClean           == rhs.onlyClean
    }
}
