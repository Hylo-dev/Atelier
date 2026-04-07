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
    
    var alertManager = AlertManager()
    
    private let repository: any RepositoryProtocol<Garment, GarmentManager>
    
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
    
    init (
        _ item: Garment?,
        repository: any RepositoryProtocol<Garment, GarmentManager> = GarmentRepository()
    ) {
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
        self.imagePath           = item?.imagePath
        self.repository          = repository
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
        do {
            var finalGarment: Garment
            
            if let existingItem = item {
                updateProperties(of: existingItem)
                try repository.update(
                    item   : existingItem,
                    image  : image,
                    manager: manager
                )
                
                try applianceManager.unassignGarment(existingItem)
                finalGarment = existingItem
                
            } else {
                let newGarment = createGarmentObject()
                try repository.create(
                    item   : newGarment,
                    image  : image,
                    manager: manager
                )
                
                finalGarment = newGarment
            }
            
            try applianceManager.processUnassignedGarments([finalGarment])
            dismiss()
            
        } catch {
            alertManager.title     = "Error on Saving"
            alertManager.message   = error.localizedDescription
            alertManager.isPresent = true
        }
    }
    
    
    
    private func updateProperties(of item: Garment) {
        item.name           = self.name
        item.brand          = self.brand.isEmpty ? nil : brand
        item.price          = self.price
        item.color          = self.color.toHex() ?? "#FFFFFF"
        item.composition    = Array(self.selectedComposition)
        item.category       = self.selectedCategory
        item.subCategory    = self.selectedSubCategory
        item.season         = self.selectedSeason
        item.style          = self.selectedStyle
        item.wearCount      = self.wearCount
        item.purchaseDate   = self.purchaseDate
        item.washingSymbols = Array(self.washingSymbols)
        item.imagePath      = self.imagePath
    }
    
    
    private func createGarmentObject() -> Garment {
        return Garment(
            name          : self.name,
            brand         : self.brand.isEmpty ? nil : self.brand,
            price         : self.price,
            color         : self.color.toHex() ?? "#FFFFFF",
            composition   : Array(self.selectedComposition),
            category      : self.selectedCategory,
            subCategory   : self.selectedSubCategory,
            season        : self.selectedSeason,
            style         : self.selectedStyle,
            purchaseDate  : self.purchaseDate,
            washingSymbols: Array(self.washingSymbols),
            imagePath     : self.imagePath
        )
    }
}

