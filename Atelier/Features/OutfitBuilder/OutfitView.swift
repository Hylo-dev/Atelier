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
        
    @Binding
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
    
    
    
    // MARK: - Computed values
    
    private var visibleOutfits: [Outfit] {
        return FilterOutfitConfig.filterOutfits(
            allOutfits : self.outfits,
            config     : self.filter
        )
    }
    
    
    
    // MARK: - Add Outfit Sheet values
    
    @State
    private var isAddOutfitSheetVisible: Bool = false
    
    
    
    // MARK: - Filter Outfit Sheet values
    
    @State
    private var filter = FilterOutfitConfig()
    
    @State
    private var showFilterSheet: Bool = false
    
    
    
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
        }
        .onChange(of: self.outfits) {
            self.updateSeason()
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
                Button("Filter", systemImage: "line.3.horizontal.decrease") {  }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button("Add", systemImage: "plus") { self.isAddOutfitSheetVisible = true }
            }
        }
//        .navigationDestination(for: Garment.self) { selectedItem in
//            InfoGarmentView(
//                garmentManager: self.$outfitManager,
//                item          : selectedItem
//            )
//            
//        }
        .sheet(
            isPresented:   self.$isAddOutfitSheetVisible,
            onDismiss  : { self.isAddOutfitSheetVisible = false }
        ) {
            NavigationStack {
                AddOutfitView(outfitManager: self.$outfitManager)
            }
        }
//        .sheet(item: self.$selectedItem) { germent in
//            
//            NavigationStack {
//                ModifyGarmentView(
//                    garmentManager: self.$garmentManager,
//                    garment       : germent
//                )
//            }
//        }
        
    }
    
    
    
    // MARK: - Views
    
    @ViewBuilder
    private func scrollableGrid(for season: String) -> some View {
        ScrollView(.vertical) {
            LazyVGrid(columns: Self.columns, spacing: 20) {
                
                ForEach(self.items(for: season)) { item in
                    
                    NavigationLink(value: item) {
                        ModelCardView(
                            title      : item.name,
                            subheadline: nil,
                            imagePath  : item.fullLookImagePath
                        )
                        .equatable()
                        .id(item.id)
                        .contextMenu {
                            
                            Button {
                                self.selectedItem = item
                                
                            } label: {
                                Label("Edit Details", systemImage: "pencil")
                            }
                            
                            Button(role: .destructive) {
                                self.outfitManager?.deleteOutfit(item)
                                
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
        }
        .contentMargins(.top, 150, for: .scrollContent)
        .scrollIndicators(.hidden)
        
        
    }
        
    
    
    // MARK: - Handlers
    
    private func items(for season: String) -> [Outfit] {
        return if season == "All" {
            self.visibleOutfits
            
        } else {
            self.visibleOutfits.filter { $0.season.title == season }
        }
    }
    
    
    
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
}
