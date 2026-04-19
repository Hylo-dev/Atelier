//
//  GarmentContextCard.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 07/04/2026.
//

import SwiftUI


struct GarmentContextCard: View {
    
    private var item            : Garment
    private let manager         : any GarmentWearLoggable
    private let applianceManager: ApplianceProcessing
    
    
    @Bindable
    private var viewModel: WardrobeViewModel
    
    @State
    private var didTriggerDelete: Bool
    
    
    init(
        item          : Garment,
        manager       : any GarmentWearLoggable,
        processGarment: ApplianceProcessing,
        viewModel     : WardrobeViewModel
    ) {
        self.item              = item
        self.manager           = manager
        self.applianceManager  = processGarment
        self.viewModel         = viewModel
        self.didTriggerDelete  = false
    }
    
    var body: some View {
        
        bodyContextMenu(
            Button {
                viewModel.selectedItem = item
            } label: {
                ModelCardView(
                    title      : item.name,
                    subheadline: item.brand,
                    imagePath  : item.imagePath
                )
            }
        )
        .buttonStyle(.plain)
        .sensoryFeedback(.success, trigger: didTriggerDelete)
        .id(item.id)
    }
    
    private func bodyContextMenu(_ view: some View) -> some View {
        view
            .contextMenu {
                let isToWash  = item.isToWash
                let loanState = item.state == .onLoan
                                
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
                        viewModel.alertManager.title = title
                        viewModel.alertManager.message = error.localizedDescription
                        viewModel.alertManager.isPresent = true
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
                        viewModel.alertManager.title = "Error on update data"
                        viewModel.alertManager.message = error.localizedDescription
                        viewModel.alertManager.isPresent = true
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
                        viewModel.alertManager.title = "Error on loggin wear"
                        viewModel.alertManager.message = error.localizedDescription
                        viewModel.alertManager.isPresent = true
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
                    viewModel.editableItem = item
                    
                } label: {
                    Label("Edit Details", systemImage: "pencil")
                }
                
                Button(role: .destructive) {
                    didTriggerDelete.toggle()
                    
                    do {
                        try manager.delete(item)
                        
                    } catch {
                        viewModel.alertManager.title = "Error on deleted data"
                        viewModel.alertManager.message = error.localizedDescription
                        viewModel.alertManager.isPresent = true
                    }
                    
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
    }
}
