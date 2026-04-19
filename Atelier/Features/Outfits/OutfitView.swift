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
    
    var outfitState: TabFilterService
    
    var title: String
    
    init(
        title    : String,
        outfitState: TabFilterService
    ) {
        self.title           = title
        self.outfitState     = outfitState
    }
    
    var body: some View {
        let _ = Self._printChanges()
        
        bodyModifiers(
            ZStack {
                OutfitListContent(
                    title          : title,
                    filterManager  : filterManager,
                    outfitViewModel: outfitViewModel,
                    outfitState    : outfitState
                )
            }
            .animation(
                .snappy,
                value: filterManager.predicate.description
            )
        )
        .sensoryFeedback(
            .success,
            trigger: outfitViewModel.isDeleted
        )
        .onChange(of: outfitViewModel.processedOutfit) { _, newValue in
            if outfitState.items != newValue.tag {
                outfitState.items = newValue.tag
            }
        }
        .onChange(of: filterManager.isFiltering) { _, newValue in
            outfitState.hiddenSectionBar = newValue
        }
        .onChange(of: outfitViewModel.navigatedOutfit) { _, newValue in
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
            .sheet(
                isPresented: $outfitViewModel.isFilterSheetVisible,
                onDismiss  : {
                    withAnimation(.snappy) {
                        filterManager.update()
                    }
                }
            ) {
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
