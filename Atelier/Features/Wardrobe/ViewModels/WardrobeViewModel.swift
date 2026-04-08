//
//  WardrobeViewModel.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 07/04/2026.
//

import Observation

@Observable
final class WardrobeViewModel {
    
    var alertManager: AlertManager
        
    var isAddGarmentSheetVisible: Bool = false
    
    var selectedItem: Garment?
    
    var navigatedGarment: Garment?
    
    var filterManager: FilterGarmentConfig
    
    var isFilterSheetVisible: Bool = false
    
    var processedGarments: Processed<Garment>
    
    init(filter: FilterGarmentConfig = FilterGarmentConfig()) {
        self.alertManager             = AlertManager()
        self.isAddGarmentSheetVisible = false
        self.selectedItem             = nil
        self.navigatedGarment         = nil
        self.filterManager            = filter
        self.isFilterSheetVisible     = false
        self.processedGarments        = Processed()
    }
}

