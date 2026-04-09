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
    
    @Query
    private var garments: [Garment]
    
    @Bindable
    var filterManager: FilterManager<FilterGarmentConfig>
    
    @Bindable
    var wardrobeViewModel: WardrobeViewModel
    
    @Bindable
    var wardrobeState: TabFilterService
    
    init(
        filterManager    : FilterManager<FilterGarmentConfig>,
        wardrobeViewModel: WardrobeViewModel,
        wardrobeState    : TabFilterService
    ) {
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
        let _ = Self._printChanges()
        
        Group {
            if garments.isEmpty && !filterManager.isFiltering {
                emptyView
                
            } else if garments.isEmpty && filterManager.isFiltering {
                emptyFilteredView
                
            } else {
                pagingView
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
            description: Text("Try adjusting your filters.")
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
