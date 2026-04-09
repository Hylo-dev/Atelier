//
//  OutfitContextCard.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 08/04/2026.
//

import SwiftUI


struct OutfitContextCard: View {
    private let item            : Outfit
    private let garmentManager  : GarmentManager
    private let applianceManager: ApplianceManager
    private let manager         : OutfitManager
    
    @Bindable
    private var viewModel: OutfitViewModel
    
    @State
    private var taskDeletedCompleted: Bool
    
    @State
    private var subTitle: String?
    
    
    init(
        outfit          : Outfit,
        garmentManager  : GarmentManager,
        applianceManager: ApplianceManager,
        manager         : OutfitManager,
        viewModel       : OutfitViewModel
    ) {
        
        self.item                 = outfit
        self.garmentManager       = garmentManager
        self.applianceManager     = applianceManager
        self.manager              = manager
        self.viewModel            = viewModel
        self.taskDeletedCompleted = false
    }
    
    var body: some View {
        bodyContextMenu(
            Button {
                viewModel.navigatedOutfit = item
                
            } label: {
                ModelCardView(
                    title      : item.name,
                    subheadline: subTitle,
                    imagePath  : item.fullLookImagePath
                )
                .opacity(subTitle != nil ? 0.7 : 1)
                
            }
        )
        .buttonStyle(.plain)
        .sensoryFeedback(.success, trigger: self.taskDeletedCompleted)
        .onAppear {
            subTitle = item.garments.count <= 1 ? "Incomplete outfit" : nil
        }
        
    }
    
    
    private func bodyContextMenu(_ view: some View) -> some View {
        view
            .contextMenu {
                Button {
                    do {
                        try manager.moveOutfitToWash(
                            for           : item,
                            garmentManager: garmentManager,
                            processGarment: applianceManager
                        )
                    } catch {
                        viewModel.alertManager.title = ""
                        viewModel.alertManager.message = error.localizedDescription
                        viewModel.alertManager.isPresent = true
                    }
                    
                } label: {
                    Label("Wash Entire Outfit", systemImage: "washer")
                }
                
                
                Button {
                    do {
                        try manager.toggleOutfitLoan(item)
                        
                    } catch {
                        viewModel.alertManager.title = "Error on set Loan State"
                        viewModel.alertManager.message = error.localizedDescription
                        viewModel.alertManager.isPresent = true
                    }
                    
                } label: {
                    let isOnLoan = item.isOnLoan
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
                        viewModel.alertManager.title = "Error on loggin wear"
                        viewModel.alertManager.message = error.localizedDescription
                        viewModel.alertManager.isPresent = true
                    }
                    
                } label: {
                    Label("Log wear", systemImage: "checkmark.seal")
                }
                
                
                
                Divider()
                
                
                
                Button {
                    viewModel.selectedItem = item
                } label: {
                    Label("Edit Details", systemImage: "pencil")
                }
                
                
                Button(role: .destructive) {
                    do {
                        try self.manager.delete(item)
                        self.taskDeletedCompleted.toggle()
                    } catch {
                        viewModel.alertManager.title = "Error on delete outfit"
                        viewModel.alertManager.message = error.localizedDescription
                        viewModel.alertManager.isPresent = true
                    }
                    
                } label: {
                    Label("Delete", systemImage: "trash")
                }
                
            }
    }
}
