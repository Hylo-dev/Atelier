//
//  FilteredOutfitView.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 09/04/2026.
//

import SwiftUI
import SwiftData

struct OutfitListContent: View {
    
    @Environment(OutfitManager.self)
    private var outfitManager
    
    @Environment(GarmentManager.self)
    private var garmentManager
    
    @Environment(ApplianceManager.self)
    private var applianceManager
    
    @Query
    private var outfits: [Outfit]
    
    @Bindable
    private var filterManager: FilterManager<FilterOutfitConfig>
    
    @Bindable
    private var outfitViewModel : OutfitViewModel
    
    @Bindable
    var outfitState: TabFilterService
    
    init(
        filterManager  : FilterManager<FilterOutfitConfig>,
        outfitViewModel: OutfitViewModel,
        outfitState    : TabFilterService
    ) {
        self.filterManager   = filterManager
        self.outfitViewModel = outfitViewModel
        self.outfitState     = outfitState
        
        _outfits = Query(
            filter: filterManager.predicate,
            sort  : \Outfit.name,
            order : .reverse
        )
    }
    
    var body: some View {
        Group {
            if outfits.isEmpty && !filterManager.isFiltering {
                emptyStateView
                
            } else if outfits.isEmpty && filterManager.isFiltering {
                emptyFilteredView
                
            } else {
                pagingView
            }
        }
        .onChange(of: outfits, initial: true) { old, newValue in
            outfitViewModel.handleGarmentChange(newValue, manager: outfitManager)
        }
    }
    
    private var emptyStateView: some View {
        ContentUnavailableView(
            "Outfits Empty",
            systemImage: "tshirt",
            description: Text("Time to create your drip")
        )
        .containerRelativeFrame(.vertical)
    }
    
    private var emptyFilteredView: some View {
        ContentUnavailableView(
            "No Outfits Found",
            systemImage: "magnifyingglass",
            description: Text("Try adjusting your filters.")
        )
        .containerRelativeFrame(.vertical)
    }
    
    private var pagingView: some View {
        LiquidPagingView(
            selection       : self.$outfitState.selection,
            onProgressChange: { newVal in
                if self.outfitState.progress != newVal {
                    self.outfitState.progress = newVal
                }
            },
            items           : self.outfitState.items,
            isEnabled       : self.outfitState.isPagesEnabled
        ) { season in
            let visibles = outfitViewModel.processedOutfit.grouped[season] ?? []
            
            VerticalScrollGridView(items: visibles) { item in
                OutfitContextCard(
                    outfit          : item,
                    garmentManager  : garmentManager,
                    applianceManager: applianceManager,
                    manager         : outfitManager,
                    viewModel       : outfitViewModel
                )
                .id(item.persistentModelID)
            }
        }
        .ignoresSafeArea(.container, edges: .top)
    }
}
