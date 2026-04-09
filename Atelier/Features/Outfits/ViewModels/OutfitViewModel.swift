//
//  OutfitViewModel.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 08/04/2026.
//

import Observation
import SwiftUI

@Observable
final class OutfitViewModel {
    
    var alertManager: AlertManager
    
    var selectedItem: Outfit?
    
    var navigatedOutfit: Outfit?
    
    var isDeleted: Bool
    
    var isAddOutfitSheetVisible: Bool
        
    var isFilterSheetVisible: Bool
    
    var processedOutfit: Processed<Outfit>
    
    private var processingTask: Task<Void, Never>?
    
    init() {
        self.alertManager            = AlertManager()
        self.selectedItem            = nil
        self.navigatedOutfit         = nil
        self.isDeleted               = false
        self.isAddOutfitSheetVisible = false
        self.isFilterSheetVisible    = false
        self.processedOutfit         = Processed()
    }
    
    func handleGarmentChange(
        _ newOutfits: [Outfit],
        manager: OutfitManager
    ) {
        processingTask?.cancel()
        
        processingTask = Task {
            let result = await manager.process(newOutfits)
            
            if !Task.isCancelled {
                await MainActor.run {
                    withAnimation(.snappy) {
                        processedOutfit = result
                    }
                }
            }
        }
    }
}
