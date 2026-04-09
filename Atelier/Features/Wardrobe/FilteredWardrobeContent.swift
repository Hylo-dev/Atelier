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
    
    
    @Query
    private var garments: [Garment]
    
    
    @Bindable
    var wardrobeState: TabFilterService
    
    @Bindable
    var wardrobeViewModel: WardrobeViewModel
    
    init(
        predicate        : Predicate<Garment>,
        wardrobeState    : TabFilterService,
        wardrobeViewModel: WardrobeViewModel
    ) {
        self.wardrobeState     = wardrobeState
        self.wardrobeViewModel = wardrobeViewModel
        
        _garments = Query(
            filter: predicate,
            sort  : \Garment.name,
            order : .reverse
        )
    }
    
    var body: some View {
        Group {
            if garments.isEmpty && !wardrobeViewModel.filterManager.isFiltering {
                emptyView
                
            } else if garments.isEmpty && wardrobeViewModel.filterManager.isFiltering {
                emptyFilteredView
                
            } else {
                pagingView
            }
        }
        .onChange(of: garments, initial: true) { _, newGarments in
            
            garmentManager.processGarments(
                newGarments,
                state: wardrobeState,
                with: wardrobeViewModel
            )
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
