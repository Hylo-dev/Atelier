//
//  FilteredOutfitView.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 09/04/2026.
//

import SwiftUI
import SwiftData

struct OutfitListContent: View {
    
    @Query
    private var outfits: [Outfit]
    
    let filterManager   : FilterManager<FilterOutfitConfig>
    let outfitViewModel : OutfitViewModel
    let outfitManager   : OutfitManager
    let garmentManager  : GarmentManager
    let applianceManager: ApplianceManager
    
    @Bindable
    var outfitState: TabFilterService
    
    init(
        predicate       : Predicate<Outfit>?,
        filterManager   : FilterManager<FilterOutfitConfig>,
        outfitViewModel : OutfitViewModel,
        outfitManager   : OutfitManager,
        garmentManager  : GarmentManager,
        applianceManager: ApplianceManager,
        outfitState     : TabFilterService
    ) {
        _outfits = Query(
            filter: predicate,
            sort  : \Outfit.name,
            order : .reverse
        )
        
        self.filterManager    = filterManager
        self.outfitViewModel  = outfitViewModel
        self.outfitManager    = outfitManager
        self.garmentManager   = garmentManager
        self.applianceManager = applianceManager
        self.outfitState      = outfitState
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
                .id(item.persistentModelID) // Cruciale per la fluidità dello scroll
            }
        }
        .ignoresSafeArea(.container, edges: .top)
    }
}
