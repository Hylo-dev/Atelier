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
    
    var filter: FilterOutfitConfig
    
    var isFilterSheetVisible: Bool
    
    var processedOutfit: ProcessedOutfits
    
    init() {
        self.alertManager            = AlertManager()
        self.selectedItem            = nil
        self.navigatedOutfit         = nil
        self.isDeleted               = false
        self.isAddOutfitSheetVisible = false
        self.filter                  = FilterOutfitConfig()
        self.isFilterSheetVisible    = false
        self.processedOutfit         = ProcessedOutfits()
    }
    
    @inline(__always)
    func updateData(
        items         : [Outfit],
        in outfitState: TabFilterService,
        with manager  : OutfitManager
    ) {
        processedOutfit = manager.processOutfits(
            items,
            with: filter
        )
        
        if outfitState.items != processedOutfit.seasons {
            outfitState.items = processedOutfit.seasons
        }
    }
}
