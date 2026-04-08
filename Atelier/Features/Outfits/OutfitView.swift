//
//  OutfitView.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 17/02/26.
//

import SwiftUI
import SwiftData

struct OutfitView: View {
    
    @Environment(OutfitManager.self)
    private var outfitManager: OutfitManager
    
    @Environment(GarmentManager.self)
    private var garmentManager: GarmentManager
    
    @Environment(ApplianceManager.self)
    private var applianceManager: ApplianceManager
    
    
    @Bindable
    var outfitState: TabFilterService
    
    var title: String
    
    
    @State
    private var outfitViewModel = OutfitViewModel()
        
    
    @Query(
        sort : \Outfit.lastWornDate,
        order: .reverse
    )
    private var outfits: [Outfit]
    
    
    var body: some View {
        bodyModifiers(
            Group {
                if outfits.isEmpty {
                    emptyStateView
                    
                } else if outfitViewModel.processedOutfit.visible.isEmpty {
                    emptyFilteredView
                    
                } else {
                    pagingView
                }
            }
        )
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
        .sensoryFeedback(.success, trigger: outfitViewModel.isDeleted)
        .onChange(of: outfits, initial: true) {
            outfitManager.processOutfits(
                outfits,
                state: outfitState,
                with: outfitViewModel
            )
        }
        .onChange(of: outfitViewModel.filterManager, initial: true) {
            outfitManager.processOutfits(
                outfits,
                state: outfitState,
                with: outfitViewModel
            )
        }
        .onChange(of: outfitViewModel.filterManager.isFiltering) { _, newValue in
            outfitState.hiddenSectionBar = newValue
        }
        .onChange(of: outfitViewModel.navigatedOutfit) { old, newValue in
            if newValue == nil {
                withAnimation {
                    outfitState.hiddenSectionBar = false
                }
            }
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
    
    private func bodyModifiers(_ view: some View) -> some View {
        view
            .navigationDestination(item: $outfitViewModel.navigatedOutfit) { item in
                InfoOutfitView(item)
                    .onAppear {
                        withAnimation {
                            outfitState.hiddenSectionBar = true
                        }
                    }
            }
            .sheet(isPresented: $outfitViewModel.isAddOutfitSheetVisible) {
                NavigationStack {
                    OutfitEditorView()
                }
            }
            .sheet(item: $outfitViewModel.selectedItem) { outfit in
                NavigationStack {
                    OutfitEditorView(outfit)
                }
            }
            .sheet(isPresented: $outfitViewModel.isFilterSheetVisible) {
                FilterOutfitView(filter: $outfitViewModel.filterManager)
            }
            .alert(
                outfitViewModel.alertManager.title,
                isPresented: $outfitViewModel.alertManager.isPresent
            ) {
                
            } message: {
                Text(outfitViewModel.alertManager.message)
            }
    }
}
