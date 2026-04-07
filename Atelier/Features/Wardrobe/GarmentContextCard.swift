//
//  GarmentContextCard.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 07/04/2026.
//

import SwiftUI


struct GarmentContextCard: View {
    
    var item            : Garment
    let manager         : any GarmentWearLoggable
    let applianceManager: ApplianceProcessing
    let onError         : (String, String) -> Void
    
    @Binding
    var selectedItem: Garment?
    
    @Binding
    var navigatedGarment: Garment?
    
    @State
    private var didTriggerDelete: Bool = false
    
    init(
        item: Garment,
        manager: any GarmentWearLoggable,
        processGarment: ApplianceProcessing,
        selectedItem: Binding<Garment?>,
        navigatedGarment: Binding<Garment?>,
        onError: @escaping (String, String) -> Void
    ) {
        self.item              = item
        self.manager           = manager
        self.applianceManager  = processGarment
        self.onError           = onError
        self._selectedItem     = selectedItem
        self._navigatedGarment = navigatedGarment
        self.didTriggerDelete  = didTriggerDelete
    }
    
    var body: some View {
        
        Button {
            navigatedGarment = item
        } label: {
            ModelCardView(
                title: self.item.name,
                subheadline: self.item.brand,
                imagePath: self.item.imagePath
            )
        }
        .buttonStyle(.plain)
        .contextMenu {
            let isToWash  = item.isToWash
            let loanState = item.state == .onLoan
            
            Text(item.name)
            
            Button {
                let title: String
                
                do {
                    if isToWash {
                        title = "Error on reset wear"
                        try manager.resetWear(
                            for : item,
                            used: applianceManager
                        )
                        
                    } else {
                        title = "Error on set state"
                        try manager.setWashState(
                            for : item,
                            used: applianceManager
                        )
                    }
                } catch {
                    onError(
                        title,
                        error.localizedDescription
                    )
                }
                
                
            } label: {
                Label(
                    isToWash ? "Mark as Clean" : "Move to Wash",
                    systemImage: isToWash ? "sparkle" : "washer"
                )
            }
            //        .disabled(!item.state.readyToWash)
            //
            Button {
                item.state = loanState ? .available : .onLoan
                do {
                    try manager.update()
                } catch {
                    onError(
                        "Error on update data",
                        error.localizedDescription
                    )
                }
                
            } label: {
                Label(
                    loanState ? "Mark as Returned" : "Mark as Lent",
                    systemImage: loanState ? "arrow.uturn.backward" : "person.2"
                )
            }
            .disabled(!item.state.readyToLent)
            
            
            
            Divider()
            
            
            
            Button {
                do {
                    let needWashing = manager.logWear(for: item, each: 1)
                    
                    if needWashing {
                        try applianceManager.processUnassignedGarments([item])
                    }
                    
                } catch {
                    onError(
                        "Error on loggin wear",
                        error.localizedDescription
                    )
                }
                
            } label: {
                Label("Log wear", systemImage: "checkmark.seal")
            }
            
            
            Button {
                
            } label: {
                Label("Add to Outfit", systemImage: "tshirt")
            }
            
            
            
            Divider()
            
            
            
            Button {
                self.selectedItem = item
                
            } label: {
                Label("Edit Details", systemImage: "pencil")
            }
            
            Button(role: .destructive) {
                didTriggerDelete.toggle()
                
                do {
                    try manager.delete(item)
                    
                } catch {
                    onError(
                        "Error on deleted data",
                        error.localizedDescription
                    )
                }
                
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .sensoryFeedback(.success, trigger: didTriggerDelete)
        .id(item.id)
    }
}
