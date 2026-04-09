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
        
    var isFilterSheetVisible: Bool = false
    
    var processedGarments: Processed<Garment>
    
    private var processingTask: Task<Void, Never>? = nil
    
    init() {
        self.alertManager             = AlertManager()
        self.isAddGarmentSheetVisible = false
        self.editableItem             = nil
        self.selectedItem             = nil
        self.isFilterSheetVisible     = false
        self.processedGarments        = Processed()
    }
    
    func handleGarmentChange(
        _ newGarments: [Garment],
        manager: GarmentManager
    ) {
        processingTask?.cancel()
        
        processingTask = Task {
            let result = await manager.process(newGarments)
            
            if !Task.isCancelled {
                processedGarments = result                
            }
        }
    }
}

