//
//  FilteredWardrobeContent.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 08/04/2026.
//

import SwiftUI
import SwiftData


struct FilteredWardrobeContent: View {
    
    @Environment(GarmentManager.self)
    private var garmentManager
    
    @Environment(ApplianceManager.self)
    private var applianceManager
    
    let title: String
    
    @Query
    private var garments: [Garment]
    
    
    @Bindable
    private var wardrobeState: TabFilterService
    
    @Bindable
    private var wardrobeViewModel: WardrobeViewModel
    
    @Bindable
    private var filterManager: FilterManager<FilterGarmentConfig>
    
    init(
        _ title          : String,
        filterManager    : FilterManager<FilterGarmentConfig>,
        wardrobeState    : TabFilterService,
        wardrobeViewModel: WardrobeViewModel
    ) {
        self.title             = title
        self.filterManager     = filterManager
        self.wardrobeState     = wardrobeState
        self.wardrobeViewModel = wardrobeViewModel
        
        _garments = Query(
            filter: filterManager.predicate,
            sort  : \Garment.name,
            order : .reverse
        )
    }
    
    var body: some View {
//        let _ = Self._printChanges()
        
        Group {
            if garments.isEmpty && !filterManager.isFiltering {
                emptyView
                
            } else if garments.isEmpty && filterManager.isFiltering {
                emptyFilteredView
                
            } else {
                pagingView
            }
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
        .onChange(of: garments, initial: true) { oldGarments, newGarments in
//            guard oldGarments != newGarments else { return }
            
            wardrobeViewModel.handleGarmentChange(
                newGarments,
                manager: garmentManager
            )
        }
        .onChange(of: wardrobeViewModel.processedGarments) { _, newValue in
            wardrobeState.items = newValue.tag
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
            items: wardrobeState.items,
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
            item          : item,
            manager       : garmentManager,
            processGarment: applianceManager,
            viewModel     : wardrobeViewModel
        )
        .id(item.id)
    }
}
