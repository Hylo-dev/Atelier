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
    
    
    @State
    private var outfitViewModel = OutfitViewModel()
    
    @State
    private var filterManager = FilterManager<FilterOutfitConfig>()
    
    
    @Bindable
    var outfitState: TabFilterService
    
    var title: String
    
    
    @Query(
        sort : \Outfit.lastWornDate,
        order: .reverse
    )
    private var outfits: [Outfit]
    
    
    var body: some View {
        bodyModifiers(
            FilteredOutfitView(
                title,
                filterManager  : filterManager,
                outfitState    : outfitState,
                outfitViewModel: outfitViewModel
            )
        )
        .sensoryFeedback(.success, trigger: outfitViewModel.isDeleted)
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
                FilterOutfitView(manager: filterManager)
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
