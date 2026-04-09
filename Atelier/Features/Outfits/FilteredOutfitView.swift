//
//  FilteredOutfitView.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 09/04/2026.
//

import SwiftUI
import SwiftData

struct FilteredOutfitView: View {
    
    @Environment(GarmentManager.self)
    private var garmentManager
    
    @Environment(ApplianceManager.self)
    private var applianceManager
    
    @Environment(OutfitManager.self)
    private var outfitManager
    
    
    let title: String
    
    @Query
    private var outfits: [Outfit]
    
    
    @Bindable
    private var outfitState: TabFilterService
    
    @Bindable
    private var outfitViewModel: OutfitViewModel
    
    @Bindable
    private var filterManager: FilterManager<FilterOutfitConfig>
    
    init(
        _ title        : String,
        filterManager  : FilterManager<FilterOutfitConfig>,
        outfitState    : TabFilterService,
        outfitViewModel: OutfitViewModel
    ) {
        self.title           = title
        self.filterManager   = filterManager
        self.outfitState     = outfitState
        self.outfitViewModel = outfitViewModel
        
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
        .toolbar {
            ToolbarItem(placement: .title) {
                Text(String(repeating: " ", count: 150))
                    .overlay(alignment: .leading) {
                        Text(self.title)
                            .font(.title)
                            .fontWeight(.bold)
                    }
            }
            
            if !outfits.isEmpty {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Filter", systemImage: "line.3.horizontal.decrease") {
                        outfitViewModel.isFilterSheetVisible = true
                    }
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button("Add", systemImage: "plus") { outfitViewModel.isAddOutfitSheetVisible = true }
            }
        }
        .onChange(of: outfits, initial: true) { oldOutfits, newOutfits in
            //            guard oldGarments != newGarments else { return }
            
            outfitViewModel.handleGarmentChange(
                newOutfits,
                manager: outfitManager
            )
        }
    }
    
    // MARK: - Views
    
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
            description: Text("Try adjusting your filters to see more results from your wardrobe.")
        )
        .containerRelativeFrame(.vertical)
    }
    
    
    private var pagingView: some View {
        LiquidPagingView(
            selection  : self.$outfitState.selection,
            onProgressChange: { newVal in
                if self.outfitState.progress != newVal {
                    self.outfitState.progress = newVal
                }
            },
            items      : self.outfitState.items,
            isEnabled  : self.outfitState.isPagesEnabled
        ) { season in
            
            let visibles = outfitViewModel.processedOutfit.grouped[season] ?? []
            VerticalScrollGridView(items: visibles) { item in
                outfitCard(item)
            }
            
            
        }
        .ignoresSafeArea(.container, edges: .top)
    }
    
    
    @ViewBuilder
    private func outfitCard(_ item: Outfit) -> some View {
        OutfitContextCard(
            outfit          : item,
            garmentManager  : garmentManager,
            applianceManager: applianceManager,
            manager         : outfitManager,
            viewModel       : outfitViewModel
        )
        .id(item.id)
    }
}
