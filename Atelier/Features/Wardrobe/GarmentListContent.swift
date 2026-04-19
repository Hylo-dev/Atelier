//
//  GarmentListContent.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 09/04/2026.
//

import SwiftUI
import SwiftData


struct GarmentListContent: View {
    
    @Environment(GarmentManager.self)
    private var garmentManager: GarmentManager
    
    @Environment(ApplianceManager.self)
    private var applianceManager: ApplianceManager
    
    
    let title: String
    
    
    @Query
    private var garments: [Garment]
    
    
    @Bindable
    private var filterManager: FilterManager<FilterGarmentConfig>
    
    @Bindable
    private var wardrobeViewModel: WardrobeViewModel
    
    @Bindable
    var wardrobeState: TabFilterService
    
    
    init(
        title            : String,
        filterManager    : FilterManager<FilterGarmentConfig>,
        wardrobeViewModel: WardrobeViewModel,
        wardrobeState    : TabFilterService
    ) {
        self.title             = title
        
        self.filterManager     = filterManager
        self.wardrobeViewModel = wardrobeViewModel
        self.wardrobeState     = wardrobeState
        
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
        .onChange(of: garments, initial: true) { _, newGarments in
            wardrobeViewModel.handleGarmentChange(
                newGarments,
                manager: garmentManager
            )
        }
    }
    
    private var emptyView: some View {
        ContentUnavailableView(
            "Your Closet is Empty",
            systemImage: "cabinet.fill",
            description: Text("Time to fill this closet up")
        )
        .containerRelativeFrame(.vertical)
    }
    
    private var emptyFilteredView: some View {
        ContentUnavailableView(
            "No Items Found",
            systemImage: "line.3.horizontal.decrease.circle",
            description: Text("We couldn't find any garments matching your current filters.")
        )
        .containerRelativeFrame(.vertical)
    }
    
    private var pagingView: some View {
        LiquidPagingView(
            selection: $wardrobeState.selection,
            onProgressChange: { if wardrobeState.progress != $0 { wardrobeState.progress = $0 } },
            items: wardrobeState.items,
            isEnabled: wardrobeState.isPagesEnabled
        ) { category in
            let visibles = wardrobeViewModel.processedGarments.grouped[category] ?? []
            
            VerticalScrollGridView(items: visibles) { item in
                GarmentContextCard(
                    item          : item,
                    manager       : garmentManager,
                    processGarment: applianceManager,
                    viewModel     : wardrobeViewModel
                )
                .id(item.persistentModelID)
            }
        }
        .ignoresSafeArea(.container, edges: .top)
    }
}
