//
//  OutfitContextCard.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 08/04/2026.
//

import SwiftUI


struct OutfitContextCard: View, Equatable {
    let outfit          : Outfit
    let garmentManager  : GarmentManager
    let applianceManager: ApplianceManager
    let manager         : OutfitManager
    let subTitleAlert   : String?
    let onError         : (String, String) -> Void
    
    @Binding
    var selectedItem: Outfit?
    
    @Binding
    var navigatedOutfit: Outfit?
    
    // MARK: - Deleted target
    @State
    private var taskDeletedCompleted: Bool = false
    
    
    init(
        outfit          : Outfit,
        garmentManager  : GarmentManager,
        applianceManager: ApplianceManager,
        manager         : OutfitManager,
        subTitleAlert   : String?,
        selectedItem    : Binding<Outfit?>,
        navigatedOutfit : Binding<Outfit?>,
        onError         : @escaping (String, String) -> Void
    ) {
        
        self.outfit = outfit
        self.garmentManager = garmentManager
        self.applianceManager = applianceManager
        self.manager = manager
        self.subTitleAlert = subTitleAlert
        self._selectedItem = selectedItem
        self._navigatedOutfit = navigatedOutfit
        self.onError = onError
    }
    
    static func == (lhs: OutfitContextCard, rhs: OutfitContextCard) -> Bool {
        return lhs.outfit.id == rhs.outfit.id &&
        lhs.outfit.name == rhs.outfit.name &&
        lhs.outfit.fullLookImagePath == rhs.outfit.fullLookImagePath &&
        lhs.subTitleAlert == rhs.subTitleAlert &&
        lhs.outfit.garments.count == rhs.outfit.garments.count
    }
    
    var body: some View {
        
        Button {
            navigatedOutfit = outfit
            
        } label: {
            ModelCardView(
                title      : self.outfit.name,
                subheadline: self.subTitleAlert,
                imagePath  : outfit.fullLookImagePath
            )
            .opacity(self.subTitleAlert != nil ? 0.7 : 1)
            .contextMenu {
                self.contextMenuButtons(for: self.outfit)
            }
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.success, trigger: self.taskDeletedCompleted)
        
    }
    
    @ViewBuilder
    private func contextMenuButtons(for item: Outfit) -> some View {
        
        Button {
            do {
                try manager.moveOutfitToWash(
                    for           : outfit,
                    garmentManager: garmentManager,
                    processGarment: applianceManager
                )
            } catch {
                onError(
                    "Error on move state",
                    error.localizedDescription
                )
            }
            
        } label: {
            Label("Wash Entire Outfit", systemImage: "washer")
        }
        
        
        Button {
            do {
                try manager.toggleOutfitLoan(outfit)
                
            } catch {
                onError(
                    "Error on set Loan State",
                    error.localizedDescription
                )
            }
            
        } label: {
            let isOnLoan = outfit.isOnLoan
            Label(
                isOnLoan ? "Mark Outfit as Returned" : "Lend Entire Outfit",
                systemImage: isOnLoan ? "arrow.uturn.backward" : "person.2"
            )
        }
        
        
        
        Divider()
        
        
        
        Button {
            do {
               try manager.logOutfitWear(
                    for           : item,
                    garmentManager: garmentManager,
                    processGarment: applianceManager
                )
            } catch {
                onError(
                    "Error on loggin wear",
                    error.localizedDescription
                )
            }
            
        } label: {
            Label("Log wear", systemImage: "checkmark.seal")
        }
        
        
        
        Divider()
        
        
        
        Button {
            self.selectedItem = item
        } label: {
            Label("Edit Details", systemImage: "pencil")
        }
        
        
        Button(role: .destructive) {
            do {
                try self.manager.delete(item)
                self.taskDeletedCompleted.toggle()
            } catch {
                onError(
                    "Error on delete outfit",
                    error.localizedDescription
                )
            }
            
        } label: {
            Label("Delete", systemImage: "trash")
        }
        
    }
}
