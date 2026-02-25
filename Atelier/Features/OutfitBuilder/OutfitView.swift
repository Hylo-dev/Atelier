//
//  OutfitView.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 17/02/26.
//

import SwiftUI
import SwiftData

struct OutfitView: View {
    
    
    
    // MARK: - Param values
    
    @Bindable
    var manager: CaptureManager
        
    @Bindable
    var seasonsState: TabFilterState
    
    var title: String
    
    
    
    // MARK: - Edit Sheet value
    
    @State
    private var selectedItem: Outfit?
    
    
    
    // MARK: - Private Attributes values
    
    @Environment(\.modelContext)
    private var context
    
    @Query(
        sort : \Outfit.lastWornDate,
        order: .reverse
    )
    private var outfits: [Outfit]
    
    @State
    private var outfitManager: OutfitManager?
    
    
    
    // MARK: - Visibles Outfits
    
    @State
    private var visibleOutfits: [Outfit] = []
    
    @State
    private var groupedOutfits: [String : [Outfit]] = [:]
    
    
    
    // MARK: - Add Outfit Sheet values
    
    @State
    private var isAddOutfitSheetVisible: Bool = false
    
    
    
    // MARK: - Filter Outfit Sheet values
    
    @State
    private var filter = FilterOutfitConfig()
    
    @State
    private var isFilterSheetVisible: Bool = false
    
    
    
    // MARK: - Static properties
    
    static private let columns = [
        GridItem(.adaptive(minimum: 150), spacing: 20)
    ]
    
    var body: some View {
//        let _ = Self._printChanges()
        
        Group {
            if self.outfits.isEmpty {
                ContentUnavailableView(
                    "Outfits Empty",
                    systemImage: "tshirt",
                    description: Text("Time to create your drip")
                )
                .containerRelativeFrame(.vertical)
                
            } else {
                LiquidPagingView(
                    selection  : self.$seasonsState.selection,
                    onProgressChange: { newVal in
                        if self.seasonsState.progress != newVal {
                            self.seasonsState.progress = newVal
                        }
                    },
                    items      : self.seasonsState.items,
                    isEnabled  : self.seasonsState.isVisible,
                ) { season in
                    self.scrollableGrid(for: season)
                }
                .ignoresSafeArea(.container, edges: .top)
            }
        }
        .onAppear {
            if self.outfitManager == nil {
                self.outfitManager = OutfitManager(context: self.context)
            }
            
            self.updateSeason()
            self.updateFilteredOutfits()
        }
        .onChange(of: self.outfits) {
            self.updateSeason()
            self.updateFilteredOutfits()
        }
        .onChange(of: self.filter) {
            self.updateFilteredOutfits()
        }
        .toolbar {
            
            ToolbarItem(placement: .title) {
                Text(String(repeating: " ", count: 50))
                    .overlay(alignment: .leading) {
                        Text(self.title)
                            .font(.title)
                            .fontWeight(.bold)
                    }
            }
                        
            ToolbarItem(placement: .topBarTrailing) {
                Button("Filter", systemImage: "line.3.horizontal.decrease") {
                    self.isFilterSheetVisible = true
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button("Add", systemImage: "plus") { self.isAddOutfitSheetVisible = true }
            }
        }
        .navigationDestination(for: Outfit.self) { selectedItem in
            InfoOutfitView(
                manager: self.$outfitManager,
                outfit : selectedItem
            )
            
        }
        .sheet(isPresented: self.$isAddOutfitSheetVisible) {
            NavigationStack {
                AddOutfitView(outfitManager: self.$outfitManager)
            }
        }
        .sheet(item: self.$selectedItem) { outfit in
            
            NavigationStack {
                ModifyOutfitView(
                    manager: self.$outfitManager,
                    outfit  : outfit
                )
            }
        }
        .sheet(isPresented: self.$isFilterSheetVisible) {
            FilterOutfitView(filter: self.$filter)
        }
        
    }
    
    
    
    // MARK: - Views
    
    @ViewBuilder
    private func scrollableGrid(for season: String) -> some View {
        ScrollView(.vertical) {
            LazyVGrid(columns: Self.columns, spacing: 20) {
                
                ForEach(self.groupedOutfits[season] ?? []) { item in
                    
                    OutfitContextCard(
                        outfit      : item,
                        manager     : self.outfitManager,
                        selectedItem: self.$selectedItem
                    )
                }
            }
            .padding(.horizontal, 16)
        }
        .contentMargins(.top, 150, for: .scrollContent)
        .scrollIndicators(.hidden)
        
        
    }
        
    
    
    // MARK: - Handlers
    
    
    @inline(__always)
    private func updateSeason() {
        let uniqueSeasons = Set(self.outfits.lazy.map {
            $0.season.title
        })
        let newSeasons = ["All"] + uniqueSeasons.sorted()
        
        if self.seasonsState.items != newSeasons {
            print("Diff found: Updating season pointer")
            self.seasonsState.items = newSeasons
            
        } else {
            print("No changes season, skipping update to save cycles")
        }
    }
    
    @inline(__always)
    private func updateFilteredOutfits() {
        self.visibleOutfits = FilterOutfitConfig.filterOutfits(
            allOutfits : self.outfits,
            config     : self.filter
        )
        
        var newGrouped: [String: [Outfit]] = [:]
        newGrouped["All"] = self.visibleOutfits
        
        let groupedByCategory = Dictionary(
            grouping: self.visibleOutfits,
            by: { $0.season.title }
        )
        
        for (category, items) in groupedByCategory {
            newGrouped[category] = items
        }
        
        self.groupedOutfits = newGrouped
    }
}

fileprivate
struct OutfitContextCard: View {
    let outfit : Outfit
    let manager: OutfitManager?
    
    @Binding
    var selectedItem: Outfit?
    
    var body: some View {
        NavigationLink(value: self.outfit) {
            ModelCardView(
                title      : self.outfit.name,
                imagePath  : self.outfit.fullLookImagePath
            )
            .equatable()
            .id(self.outfit.id)
            .contextMenu {
                self.contextMenuButtons(for: self.outfit)
            }
        }
        .buttonStyle(.plain)
    }
    
    
    
    @ViewBuilder
    private func contextMenuButtons(for item: Outfit) -> some View {
        Button {
            self.selectedItem = item
            
        } label: {
            Label("Edit Details", systemImage: "pencil")
        }
        
        Button(role: .destructive) {
            self.manager?.deleteOutfit(item)
            
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }
}
