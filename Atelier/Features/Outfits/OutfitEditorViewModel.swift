//
//  OutfitEditorViewModel.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 22/03/26.
//

import Observation
import Foundation
import UIKit

@Observable
final class OutfitEditorViewModel {
    let item: Outfit?
    
    var name: String
    
    var garments: Set<Garment>
    
    var fullLookImagePath: String?
    
    var selectedSeason: Season
    
    var selectedOccasion: Set<GarmentStyle>
    
    var lastWornDate: Date
    
    var wearCount: Int
    
    var notes: String
    
    var alertErrorMessage: String = ""
    var isAlertErrorVisible: Bool = false
    
    private let repository: any RepositoryProtocol<Outfit, OutfitManager>
    
    var isFormValid: Bool {
        let isNameValid = !name.trimmingCharacters(
            in: .whitespaces
        ).isEmpty
        
        let hasEnoughGarments = garments.count >= 2
        
        return isNameValid && hasEnoughGarments
    }
    
    init(
        _ item: Outfit?,
        repository: any RepositoryProtocol<Outfit, OutfitManager> = OutfitRepository()
    ) {
        self.item = item
        
        self.name              = item?.name             ?? ""
        self.garments          = Set(item?.garments     ?? [])
        self.fullLookImagePath = item?.fullLookImagePath
        self.selectedSeason    = item?.season           ?? .summer
        self.selectedOccasion  = Set(item?.occasion     ?? [])
        self.lastWornDate      = item?.lastWornDate     ?? .now
        self.wearCount         = item?.wearCount        ?? 0
        self.notes             = item?.notes            ?? ""
        
        self.repository        = repository
    }
    
    
    
    func handleFinishAction(
        image  : UIImage?,
        manager: OutfitManager,
        dismiss: @escaping () -> Void
    ) {
        do {
            if let existingItem = item {
                updateProperties(of: existingItem)
                
                try repository.update(
                    item : existingItem,
                    image  : image,
                    manager: manager
                )
                
            } else {
                let newGarment = createOutfitObject()
                
                try repository.create(
                    item : newGarment,
                    image  : image,
                    manager: manager
                )
            }
            
            dismiss()
        } catch {
            alertErrorMessage   = error.localizedDescription
            isAlertErrorVisible = true
        }
    }
    
    
    private func createOutfitObject() -> Outfit {
        return Outfit(
            name             : self.name,
            garments         : Array(self.garments),
            season           : self.selectedSeason,
            fullLookImagePath: self.fullLookImagePath,
            occasion         : Array(self.selectedOccasion)
        )
    }
    
    private func updateProperties(of item: Outfit) {
        item.name              = self.name
        item.season            = self.selectedSeason
        item.occasion          = Array(self.selectedOccasion)
        item.lastWornDate      = self.lastWornDate
        item.fullLookImagePath = self.fullLookImagePath
        item.wearCount         = self.wearCount
        item.garments          = Array(self.garments)
    }
}
