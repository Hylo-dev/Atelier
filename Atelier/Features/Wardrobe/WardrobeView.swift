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
    
    
    // MARK: - Parameters Val
        
    @Bindable
    var wardrobeState: TabFilterService
    
    let title: String
    
    @State
    private var wardrobeViewModel = WardrobeViewModel()
    
    
    @Query(
        sort : \Garment.name,
        order: .reverse
    )
    private var garments: [Garment]

    
    init(
        title        : String,
        wardrobeState: TabFilterService
    ) {
        self.title         = title
        self.wardrobeState = wardrobeState
    }
    
    var body: some View {
        
        bodyModifiers(
            FilteredWardrobeContent(
                predicate        : wardrobeViewModel.filterManager.predicate,
                wardrobeState    : wardrobeState,
                wardrobeViewModel: wardrobeViewModel
            )
        )
        .onChange(of: wardrobeViewModel.filterManager.isFiltering) { _, newValue in
            wardrobeState.hiddenSectionBar = newValue
        }
        .toolbar {
            ToolbarItem(placement: .title) {
                Text(String(repeating: " ", count: 150))
                    .overlay(alignment: .leading) {
                        Text(title)
                            .font(.title)
                            .fontWeight(.bold)
                    }
            }
            
            if !garments.isEmpty {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Filter", systemImage: "line.3.horizontal.decrease") {
                        wardrobeViewModel.isFilterSheetVisible = true
                    }
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button("Add", systemImage: "plus") {
                    wardrobeViewModel.isAddGarmentSheetVisible = true
                }
            }
        }
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
            .sheet(isPresented: $wardrobeViewModel.isFilterSheetVisible) {
                FilterGarmentView(
                    filters: $wardrobeViewModel.filterManager
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
