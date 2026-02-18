//
//  FilterConfig.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 18/02/26.
//

struct FilterGarmentConfig {
    var selectedBrand      : String? = nil
    var selectedCategory   : GarmentCategory? = nil
    var selectedSubCategory: GarmentSubCategory? = nil
    var selectedSeason     : Season? = nil
    var selectedStyle      : GarmentStyle? = nil
    var selectedColor      : String? = nil
    var selectedState      : GarmentState? = nil
    var onlyClean          : Bool = false
    
    var isFiltering: Bool {
        return self.selectedBrand       != nil ||
               self.selectedCategory    != nil ||
               self.selectedSubCategory != nil ||
               self.selectedSeason      != nil ||
               self.selectedStyle       != nil ||
               self.selectedColor       != nil ||
               self.selectedState       != nil ||
               self.onlyClean
    }
    
    mutating func reset() {
        self.selectedBrand       = nil
        self.selectedCategory    = nil
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
                   garment.brand != brandToFind {
                return false
            }
            
            if let categoryToFind = config.selectedCategory,
                   garment.category != categoryToFind {
                return false
            }
            
            if let subCategoryToFind = config.selectedSubCategory,
               garment.subCategory != subCategoryToFind {
                return false
            }
            
            if let seasonToFind = config.selectedSeason,
                   garment.season != seasonToFind {
                return false
            }
            
            if let styleToFind = config.selectedStyle,
               garment.style != styleToFind {
                return false
            }
            
            if let stateToFind = config.selectedState,
               garment.state != stateToFind {
                return false
            }
            
            if config.onlyClean && garment.state != .available {
                return false
            }
            
            return true
        }
    }
}
