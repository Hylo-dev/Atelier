//
//  OutfitView.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 17/02/26.
//

import SwiftUI
import SwiftData

struct OutfitView: View {
        
    @Environment(CaptureManager.self)
    var manager
        
    @Environment(\.modelContext)
    private var context
    
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
    private var outfitViemModel = OutfitViewModel()
        
    
    @Query(
        sort : \Outfit.lastWornDate,
        order: .reverse
    )
    private var outfits: [Outfit]
    
    
    // MARK: - Static properties
    
    static private let columns = [
        GridItem(.adaptive(minimum: 150), spacing: 20)
    ]
    
    
    var body: some View {
        Group {
            if outfits.isEmpty {
                ContentUnavailableView(
                    "Outfits Empty",
                    systemImage: "tshirt",
                    description: Text("Time to create your drip")
                )
                .containerRelativeFrame(.vertical)
                
            } else if outfitViemModel.processedOutfit.visible.isEmpty {
                ContentUnavailableView(
                    "No Outfits Found",
                    systemImage: "magnifyingglass",
                    description: Text("Try adjusting your filters to see more results from your wardrobe.")
                )
                .containerRelativeFrame(.vertical)
                
            } else {
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
                    self.scrollableGrid(for: season)
                }
                .ignoresSafeArea(.container, edges: .top)
                
            }
        }
        .sensoryFeedback(.success, trigger: outfitViemModel.isDeleted)
        .onChange(of: outfits, initial: true) {
            outfitViemModel.updateData(
                items: outfits,
                in   : outfitState,
                with : outfitManager
            )
        }
        .onChange(of: outfitViemModel.filter, initial: true) {
            outfitViemModel.updateData(
                items: outfits,
                in   : outfitState,
                with : outfitManager
            )
        }
        .onChange(of: outfitViemModel.filter.isFiltering) { _, newValue in
            outfitState.hiddenSectionBar = newValue
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
                        outfitViemModel.isFilterSheetVisible = true
                    }
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button("Add", systemImage: "plus") { outfitViemModel.isAddOutfitSheetVisible = true }
            }
        }
        .navigationDestination(item: $outfitViemModel.navigatedOutfit) { item in
            InfoOutfitView(item)
                .onAppear {
                    withAnimation {
                        outfitState.hiddenSectionBar = true
                    }
                }
        }
        .sheet(isPresented: $outfitViemModel.isAddOutfitSheetVisible) {
            NavigationStack {
                OutfitEditorView()
            }
        }
        .sheet(item: $outfitViemModel.selectedItem) { outfit in
            NavigationStack {
                OutfitEditorView(outfit)
            }
        }
        .sheet(isPresented: $outfitViemModel.isFilterSheetVisible) {
            FilterOutfitView(filter: $outfitViemModel.filter)
        }
        .alert(
            outfitViemModel.alertManager.title,
            isPresented: $outfitViemModel.alertManager.isPresent
        ) {
            
        } message: {
            Text(outfitViemModel.alertManager.message)
        }
        .onChange(of: outfitViemModel.navigatedOutfit) { old, newValue in
            if newValue == nil {
                withAnimation {
                    outfitState.hiddenSectionBar = false
                }
            }
        }
    }
    
    
    // MARK: - Views
    
    @ViewBuilder
    private func scrollableGrid(for season: String) -> some View {
        ScrollView(.vertical) {
            LazyVGrid(columns: Self.columns, spacing: 20) {
                
                ForEach(outfitViemModel.processedOutfit.grouped[season] ?? [], id: \.id) { item in
                    
                    let subTitle = item.garments.count <= 1 ?
                    "Incomplete outfit" : nil
                    OutfitContextCard(
                        outfit          : item,
                        garmentManager  : garmentManager,
                        applianceManager: applianceManager,
                        manager         : outfitManager,
                        subTitleAlert   : subTitle,
                        selectedItem    : $outfitViemModel.selectedItem,
                        navigatedOutfit : $outfitViemModel.navigatedOutfit
                        
                    ) { title, message in
                        outfitViemModel.alertManager.title     = title
                        outfitViemModel.alertManager.message   = message
                        outfitViemModel.alertManager.isPresent = true
                    }
                    .equatable()
                    .id(item.id)
                }
            }
            .padding(.horizontal, 16)
        }
        .contentMargins(.top, 150, for: .scrollContent)
        .scrollIndicators(.hidden)
    }
}
