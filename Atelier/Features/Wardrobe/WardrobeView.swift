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
            Group {
                if garments.isEmpty {
                    emptyView
                    
                } else if wardrobeViewModel.processedGarments.visible.isEmpty {
                    emptyFilteredView
                    
                } else {
                    pagingView
                }
            }
        )
        .onChange(of: garments, initial: true) {
            garmentManager.processGarments(
                garments,
                state: wardrobeState,
                with: wardrobeViewModel
            )
        }
        .onChange(of: wardrobeViewModel.filterManager.isFiltering) {
            garmentManager.processGarments(
                garments,
                state: wardrobeState,
                with: wardrobeViewModel
            )
        }
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
        .onChange(of: wardrobeViewModel.navigatedGarment) { old, newValue in
            if newValue == nil {
                withAnimation {
                    wardrobeState.hiddenSectionBar = false
                }
            }
        }
    }
    
    // MARK: - Subviews
    
    private var emptyView: some View {
        ContentUnavailableView(
            "Closet Empty",
            systemImage: "hanger",
            description: Text("Time to fill this closet up")
        )
        .containerRelativeFrame(.vertical)
    }
    
    
    private var emptyFilteredView: some View {
        ContentUnavailableView(
            "No Garments Found",
            systemImage: "magnifyingglass",
            description: Text("Try adjusting your filters to see more results from your wardrobe.")
        )
        .containerRelativeFrame(.vertical)
    }
    
    
    private var pagingView: some View {
        LiquidPagingView(
            selection: $wardrobeState.selection,
            onProgressChange: { newVal in
                if wardrobeState.progress != newVal {
                    wardrobeState.progress = newVal
                }
            },
            items    : wardrobeState.items,
            isEnabled: wardrobeState.isPagesEnabled
        ) { category in
            
            let visibles = wardrobeViewModel.processedGarments.grouped[category] ?? []
            VerticalScrollGridView(items: visibles) { item in
                garmentCard(item)
            }
            
        }
        .ignoresSafeArea(.container, edges: .top)
    }
    
    
    @ViewBuilder
    private func garmentCard(_ item: Garment) -> some View {
        GarmentContextCard(
            item            : item,
            manager         : garmentManager,
            processGarment  : applianceManager,
            selectedItem    : $wardrobeViewModel.selectedItem,
            navigatedGarment: $wardrobeViewModel.navigatedGarment
            
        ) { title, message in
            wardrobeViewModel.alertManager.title     = title
            wardrobeViewModel.alertManager.message   = message
            wardrobeViewModel.alertManager.isPresent = true
        }
        .id(item.id)
    }
    
    private func bodyModifiers(_ view: some View) -> some View {
        view
            .navigationDestination(item: $wardrobeViewModel.navigatedGarment) { item in
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
            .sheet(item: $wardrobeViewModel.selectedItem) { germent in
                NavigationStack {
                    GarmentEditorView(garment: germent)
                }
            }
            .sheet(isPresented: $wardrobeViewModel.isFilterSheetVisible) {
                FilterGarmentView(
                    filters: $wardrobeViewModel.filterManager,
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
