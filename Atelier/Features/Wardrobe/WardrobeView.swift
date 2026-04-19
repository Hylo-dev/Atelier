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
    
    @Environment(ApplianceManager.self)
    private var applianceManager
    
    let title: String
    
    var wardrobeState: TabFilterService
    
    @State
    private var wardrobeViewModel = WardrobeViewModel()
    
    @State
    private var filterManager = FilterManager<FilterGarmentConfig>()
    
    var body: some View {
//        let _ = Self._printChanges()
        
        bodyModifiers(
            GarmentListContent(
                title            : title,
                filterManager    : filterManager,
                wardrobeViewModel: wardrobeViewModel,
                wardrobeState    : wardrobeState
            )
            .animation(
                .snappy,
                value: filterManager.predicate.description
            )
        )
        .onChange(of: wardrobeViewModel.processedGarments) { _, newValue in
            if wardrobeState.items != newValue.tag {
                wardrobeState.items = newValue.tag
            }
        }
        .onChange(of: filterManager.isFiltering) { _, newValue in
            wardrobeState.hiddenSectionBar = newValue
        }
        .onChange(of: wardrobeViewModel.selectedItem) { _, newValue in
            if newValue == nil {
                withAnimation { wardrobeState.hiddenSectionBar = false }
            }
        }
    }
    
    private func bodyModifiers(_ view: some View) -> some View {
        view
            .navigationDestination(item: $wardrobeViewModel.selectedItem) { item in
                InfoGarmentView(item, garmentManager: self.garmentManager)
                    .onAppear {
                        withAnimation { wardrobeState.hiddenSectionBar = true }
                    }
            }
            .sheet(isPresented: $wardrobeViewModel.isAddGarmentSheetVisible) {
                NavigationStack { GarmentEditorView() }
            }
            .sheet(isPresented: $wardrobeViewModel.isFilterSheetVisible, onDismiss: {
                withAnimation(.snappy) { filterManager.update() }
            }) {
                FilterGarmentView(manager: filterManager, brands: wardrobeViewModel.processedGarments.brands)
            }
            .sheet(item: $wardrobeViewModel.editableItem) { garment in
                NavigationStack { GarmentEditorView(garment: garment) }
            }
            .alert(wardrobeViewModel.alertManager.title, isPresented: $wardrobeViewModel.alertManager.isPresent) {
                
            } message: {
                Text(wardrobeViewModel.alertManager.message)
            }
    }
}
