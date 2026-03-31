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
    
    var isFormValid: Bool {
        let isNameValid = !name.trimmingCharacters(
            in: .whitespaces
        ).isEmpty
        
        let hasEnoughGarments = garments.count >= 2
        
        return isNameValid && hasEnoughGarments
    }
    
    init(_ item: Outfit?) {
        self.item = item
        
        self.name              = item?.name             ?? ""
        self.garments          = Set(item?.garments     ?? [])
        self.fullLookImagePath = item?.fullLookImagePath
        self.selectedSeason    = item?.season           ?? .summer
        self.selectedOccasion  = Set(item?.occasion     ?? [])
        self.lastWornDate      = item?.lastWornDate     ?? .now
        self.wearCount         = item?.wearCount        ?? 0
        self.notes             = item?.notes            ?? ""
    }
    
    
    
    func handleFinishAction(
        image      : UIImage?,
        manager    : OutfitManager,
        successTask: @escaping () -> Void
    ) {
        let success = if item == nil {
            saveOutfit(
                image,
                use: manager
            )
            
        } else {
            updateOutfit(
                image,
                use: manager
            )
        }
        
        if success { successTask() }
    }
    
    private func saveOutfit(
        _   image  : UIImage?,
        use manager: OutfitManager
    ) -> Bool {
        
        if let imageToSave = image {
            let result = ImageStorage.saveImage(imageToSave)
            
            switch result {
                case .success(let filename):
                    fullLookImagePath = (filename as NSString).lastPathComponent
                    
                case .failure(let error):
                    alertErrorMessage   = error.localizedDescription
                    isAlertErrorVisible = true
                    return false
            }
        }
        
        let newOutfit = Outfit(
            name             : self.name,
            garments         : Array(self.garments),
            season           : self.selectedSeason,
            fullLookImagePath: self.fullLookImagePath,
            occasion         : Array(self.selectedOccasion)
        )
        
        manager.insert(newOutfit)
        return true
    }
    
    private func updateOutfit(
        _   image  : UIImage?,
        use manager: OutfitManager
    ) -> Bool {
        guard let outfit = item else { return false }
        
        if let imageToSave = image {
            
            if let oldPath = item?.fullLookImagePath {
                ImageStorage.deleteImage(filename: oldPath)
            }
            
            switch ImageStorage.saveImage(imageToSave) {
                case .success(let filename):
                    fullLookImagePath = (filename as NSString).lastPathComponent
                    
                case .failure(let error):
                    alertErrorMessage   = error.localizedDescription
                    isAlertErrorVisible = true
                    return false
            }
        }
        
        outfit.name              = self.name
        outfit.season            = self.selectedSeason
        outfit.occasion          = Array(self.selectedOccasion)
        outfit.lastWornDate      = self.lastWornDate
        outfit.fullLookImagePath = self.fullLookImagePath
        outfit.wearCount         = self.wearCount
        outfit.garments          = Array(self.garments)
        
        
        manager.update()
        return true
    }
}
