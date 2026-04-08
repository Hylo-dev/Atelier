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
    
    var editableItem: Garment?
    
    var selectedItem: Garment?
    
    var filterManager: FilterGarmentConfig
    
    var isFilterSheetVisible: Bool = false
    
    var processedGarments: Processed<Garment>
    
    init(filter: FilterGarmentConfig = FilterGarmentConfig()) {
        self.alertManager             = AlertManager()
        self.isAddGarmentSheetVisible = false
        self.editableItem             = nil
        self.selectedItem             = nil
        self.filterManager            = filter
        self.isFilterSheetVisible     = false
        self.processedGarments        = Processed()
    }
}

