//
//  InventoryView.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 15/02/26.
//

import SwiftUI
import SwiftData

struct WardrobeView: View {
        
    @Environment(GarmentManager.self)
    private var garmentManager
    
    
    // MARK: - Parameters Val
        
    @Bindable
    var wardrobeState: TabFilterService
    
    let title: String
    
    @State
    private var wardrobeViewModel = WardrobeViewModel()
    
    @State
    private var filterManager = FilterManager<FilterGarmentConfig>()

    
    init(
        title        : String,
        wardrobeState: TabFilterService
    ) {
        self.title         = title
        self.wardrobeState = wardrobeState
    }
    
    var body: some View {
        let _ = Self._printChanges()
        
        bodyModifiers(
            FilteredWardrobeContent(
                title,
                filterManager    : filterManager,
                wardrobeState    : wardrobeState,
                wardrobeViewModel: wardrobeViewModel
            )
        )
        .onChange(of: wardrobeViewModel.selectedItem) { old, newValue in
            if newValue == nil {
                withAnimation {
                    wardrobeState.hiddenSectionBar = false
                }
            }
        }
    }
    
    
    // MARK: - Subviews
    
    private func bodyModifiers(_ view: some View) -> some View {
        view
            .navigationDestination(item: $wardrobeViewModel.selectedItem) { item in
                InfoGarmentView(
                    item,
                    garmentManager: self.garmentManager
                )
                .onAppear {
                    withAnimation {
                        wardrobeState.hiddenSectionBar = true
                    }
                }
            }
            .sheet(isPresented: $wardrobeViewModel.isAddGarmentSheetVisible) {
                NavigationStack {
                    GarmentEditorView()
                }
            }
            .sheet(item: $wardrobeViewModel.editableItem) { germent in
                NavigationStack {
                    GarmentEditorView(garment: germent)
                }
            }
            .sheet(
                isPresented: $wardrobeViewModel.isFilterSheetVisible,
                onDismiss: {
                    filterManager.update()
                }
            ) {
                FilterGarmentView(
                    manager: filterManager,
                    brands : wardrobeViewModel.processedGarments.brands
                )
            }
            .alert(
                wardrobeViewModel.alertManager.title,
                isPresented: $wardrobeViewModel.alertManager.isPresent
            ) {
                
            } message: {
                Text(wardrobeViewModel.alertManager.message)
            }
    }
}
