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
    
    var title: String
    
    var isAddGarmentSheetVisible: Bool = false
    
    var selectedItem: Garment?
    
    var navigatedGarment: Garment?
    
    var filter: FilterGarmentConfig
    
    var isFilterSheetVisible: Bool = false
    
    init(
        title: String,
        filter: FilterGarmentConfig = FilterGarmentConfig()
    ) {
        self.alertManager             = AlertManager()
        self.title                    = title
        self.isAddGarmentSheetVisible = false
        self.selectedItem             = nil
        self.navigatedGarment         = nil
        self.filter                   = filter
        self.isFilterSheetVisible     = false
    }
    
    @inline(__always)
    func updateData(
        _ garments   : [Garment],
        wardrobeState: TabFilterService,
        service      : GarmentProcessing
    ) {
        service.processGarments(
            garments,
            with: filter
        )
        
        if wardrobeState.items != service.availableCategories {
            wardrobeState.items = service.availableCategories
        }
    }
}

