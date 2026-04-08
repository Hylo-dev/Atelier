//
//  OutfitViewModel.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 08/04/2026.
//

import Observation

@Observable
final class OutfitViewModel {
    
    var alertManager: AlertManager
    
    var selectedItem: Outfit?
    
    var navigatedOutfit: Outfit?
    
    var isDeleted: Bool
    
    var isAddOutfitSheetVisible: Bool
    
    var filterManager: FilterOutfitConfig
    
    var isFilterSheetVisible: Bool
    
    var processedOutfit: Processed<Outfit>
    
    init() {
        self.alertManager            = AlertManager()
        self.selectedItem            = nil
        self.navigatedOutfit         = nil
        self.isDeleted               = false
        self.isAddOutfitSheetVisible = false
        self.filterManager           = FilterOutfitConfig()
        self.isFilterSheetVisible    = false
        self.processedOutfit         = Processed()
    }
}
