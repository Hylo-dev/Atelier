//
//  GarmentEditorViewModel.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 22/03/26.
//

import Observation
import SwiftUI

@Observable
final class GarmentEditorViewModel {
    
    var name: String
    var brand: String
    var price: Double?
    var color: Color
    var wearCount: Int
    
    var selectedFabrics: Set<GarmentFabric>
    var selectedComposition: [GarmentComposition]
    var selectedCategory: GarmentCategory
    var selectedSubCategory: GarmentSubCategory
    var selectedSeason: Season
    var selectedStyle: GarmentStyle
    var selectedState: GarmentState?
    
    var washingSymbols: Set<LaundrySymbol>
    var purchaseDate: Date
    
    var imagePath: String?
    
    var alertErrorMessage: String = ""
    var isAlertErrorVisible: Bool = false
    
    var currentTotalComposition: Int {
        Int(
            selectedComposition.reduce(0) { $0 + $1.percentual }
        )
    }
    
    var isFormValid: Bool {
        let isNameValid = !name.trimmingCharacters(in: .whitespaces).isEmpty
        let isCompositionValid = currentTotalComposition <= 100
        
        return isNameValid && isCompositionValid
    }
    
    init (_ item: Garment?) {
        self.name  = item?.name  ?? ""
        self.brand = item?.brand ?? ""
        self.price = item?.price
        
        self.color = if let hexString = item?.color {
            Color(hex: hexString)
            
        } else {
            .accentColor
        }
        self.wearCount = item?.wearCount ?? 0
        
        self.selectedFabrics = Set(
            item?.composition.map { $0.fabric } ?? []
        )
        
        self.selectedComposition = item?.composition ?? []
        self.selectedCategory    = item?.category    ?? .top
        self.selectedSubCategory = item?.subCategory ?? .top
        self.selectedSeason      = item?.season      ?? .winter
        self.selectedStyle       = item?.style       ?? .casual
        self.selectedState       = item?.state       ?? .available
        
        self.washingSymbols      = Set(item?.washingSymbols ?? [])
        self.purchaseDate        = item?.purchaseDate ?? .now
        self.imagePath           = item?.imagePath ?? ""
    }
    
    
    
    func selectedFabricsChanged(
        _ oldValue: Set<GarmentFabric>,
        _ newValue: Set<GarmentFabric>
    ) {
        guard !newValue.isEmpty else {
            selectedComposition = []
            return
        }
        
        let keptFabrics = newValue.intersection(oldValue)
        let addedFabrics = newValue.subtracting(oldValue)
        
        var keptCompositions: [GarmentComposition] = []
        var currentKeptSum: Double = 0.0
        
        for fabric in keptFabrics {
            if let existing = selectedComposition.first(where: { $0.fabric == fabric }) {
                keptCompositions.append(existing)
                currentKeptSum += existing.percentual
            }
        }
        
        var newCompositionList: [GarmentComposition] = []
        
        if !addedFabrics.isEmpty {
            let availableSpace = 100.0 - currentKeptSum
            
            if availableSpace > 0.1 {
                let shareForNew = availableSpace / Double(addedFabrics.count)
                newCompositionList.append(contentsOf: keptCompositions)
                
                for fabric in addedFabrics {
                    newCompositionList.append(GarmentComposition(fabric: fabric, percentual: shareForNew))
                }
                
            } else {
                let equalShare         = 100.0 / Double(newValue.count)
                let totalSpaceForAdded = equalShare * Double(addedFabrics.count)
                let spaceForKept       = 100.0 - totalSpaceForAdded
                
                for var composition in keptCompositions {
                    if currentKeptSum > 0 {
                        composition.percentual = (composition.percentual / currentKeptSum) * spaceForKept
                        
                    } else {
                        composition.percentual = spaceForKept / Double(keptCompositions.count)
                    }
                    
                    newCompositionList.append(composition)
                }
                
                for fabric in addedFabrics {
                    newCompositionList.append(GarmentComposition(fabric: fabric, percentual: equalShare))
                }
            }
            
        } else {
            for var composition in keptCompositions {
                if currentKeptSum > 0 {
                    composition.percentual = (composition.percentual / currentKeptSum) * 100.0
                    
                } else {
                    composition.percentual = 100.0 / Double(keptCompositions.count)
                }
                
                newCompositionList.append(composition)
            }
        }
        
        selectedComposition = newCompositionList
    }
    
    
    
    func handleFinishAction(
        _ item          : Garment?,
        image           : UIImage?,
        manager         : GarmentManager,
        applianceManager: ApplianceManager,
        sessions        : [LaundrySession],
        dismiss         : @escaping () -> Void
    ) {
        let garmentToProcess: Garment?
        
        if item == nil {
            garmentToProcess = saveGarment(
                image,
                manager: manager
            )
            
        } else {
            garmentToProcess = updateGarment(
                item,
                image,
                manager: manager
            )
            if let g = garmentToProcess {
                applianceManager.unassignGarment(g)
            }
        }
        
        if let finalGarment = garmentToProcess {
            applianceManager.processUnassignedGarments(
                [finalGarment], sessions
            )
            
            dismiss()
        }
    }
    
    
    private func saveGarment(
        _ uiImage: UIImage?,
        manager: GarmentManager
    ) -> Garment? {
        if let imageToSave = uiImage {
            
            let result = ImageStorage.saveImage(imageToSave)
            switch result {
                case .success(let filename):
                    imagePath = (filename as NSString).lastPathComponent
                    
                case .failure(let error):
                    alertErrorMessage   = error.localizedDescription
                    isAlertErrorVisible = true
                    return nil
            }
        }
        
        let newGarment = Garment(
            name          : self.name,
            brand         : self.brand.isEmpty ? nil : self.brand,
            price         : self.price,
            color         : self.color.toHex() ?? "nil",
            composition   : Array(self.selectedComposition),
            category      : self.selectedCategory,
            subCategory   : self.selectedSubCategory,
            season        : self.selectedSeason,
            style         : self.selectedStyle,
            purchaseDate  : self.purchaseDate,
            
            washingSymbols: Array(self.washingSymbols),
            
            imagePath     : self.imagePath
        )
        
        manager.insert(newGarment)
        return newGarment
    }
    
    
    private func updateGarment(
        _ item: Garment?,
        _ uiImage: UIImage?,
        manager: GarmentManager
    ) -> Garment? {
        guard let garment = item else { return nil }
        
        if let imageToSave = uiImage {
            
            if let oldPath = garment.imagePath {
                ImageStorage.deleteImage(filename: oldPath)
            }
            
            let result = ImageStorage.saveImage(imageToSave)
            switch result {
                case .success(let filename):
                    self.imagePath = (filename as NSString).lastPathComponent
                    
                case .failure(let error):
                    alertErrorMessage   = error.localizedDescription
                    isAlertErrorVisible = true
                    return nil
            }
        }
        
        garment.name           = self.name
        garment.brand          = self.brand.isEmpty ? nil : self.brand
        garment.price          = self.price
        garment.color          = self.color.toHex() ?? "nil"
        
        // Updated properties
        garment.composition    = Array(self.selectedComposition)
        garment.category       = self.selectedCategory
        garment.subCategory    = self.selectedSubCategory
        garment.season         = self.selectedSeason
        garment.style          = self.selectedStyle
        garment.wearCount      = self.wearCount
        
        garment.washingSymbols = Array(self.washingSymbols)
        garment.purchaseDate   = self.purchaseDate
        garment.imagePath      = self.imagePath
        
        manager.update()
        return garment
    }
}

