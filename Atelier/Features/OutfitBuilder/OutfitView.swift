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
    
    @State
    private var isDeleted: Bool = false
    
    
    
    // MARK: - Private Attributes values
    
    @Environment(\.modelContext)
    private var context
    
    @Environment(OutfitManager.self)
    private var outfitManager: OutfitManager
    
    @Query(
        sort : \Outfit.lastWornDate,
        order: .reverse
    )
    private var outfits: [Outfit]
    
    
    
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
    
    
    
    // MARK: - Refresh Trigger
    
    private var outfitsUpdateTrigger: Int {
        var hasher = Hasher()
        
        for outfit in outfits {
            hasher.combine(outfit.id)
            hasher.combine(outfit.name)
            hasher.combine(outfit.season.title)
            hasher.combine(outfit.fullLookImagePath)
            hasher.combine(outfit.garments.count)
            hasher.combine(outfit.lastWornDate)
        }
        
        return hasher.finalize()
    }
    
    var body: some View {
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
                    isEnabled  : self.seasonsState.isVisible
                ) { season in
                    self.scrollableGrid(for: season)
                }
                .ignoresSafeArea(.container, edges: .top)
                
            }
        }
        .sensoryFeedback(.success, trigger: isDeleted)
        .onAppear {
            self.updateData()
        }
        .onChange(of: outfitsUpdateTrigger) {
            self.updateData()
        }
        .onChange(of: self.filter) {
            self.updateData()
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
        .navigationDestination(for: Outfit.self) { selectedOutfit in
            InfoOutfitView(selectedOutfit)
        }
        .sheet(isPresented: self.$isAddOutfitSheetVisible) {
            NavigationStack {
                OutfitEditorView()
            }
        }
        .sheet(item: self.$selectedItem) { outfit in
            NavigationStack {
                OutfitEditorView(outfit)
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
                
                ForEach(self.outfitManager.groupedOutfits[season] ?? [], id: \.id) { item in
                    
                    let subTitle = item.garments.count <= 1 ?
                    "Incomplete outfit" : nil
                    OutfitContextCard(
                        outfit       : item,
                        manager      : self.outfitManager,
                        subTitleAlert: subTitle,
                        selectedItem : self.$selectedItem
                    )
                    .equatable()
                    .id(item.id)
                }
            }
            .padding(.horizontal, 16)
        }
        .contentMargins(.top, 150, for: .scrollContent)
        .scrollIndicators(.hidden)
    }
    
    
    // MARK: - Handlers
    
    @inline(__always)
    private func updateData() {
        self.outfitManager.processOutfits(self.outfits, with: self.filter)
        
        if self.seasonsState.items != outfitManager.availableSeasons {
            self.seasonsState.items = outfitManager.availableSeasons
        }
    }
}

fileprivate
struct OutfitContextCard: View, Equatable {
    let outfit       : Outfit
    let manager      : OutfitManager?
    let subTitleAlert: String?
    
    @Binding
    var selectedItem: Outfit?
    
    // MARK: - Deleted target
    @State
    private var taskDeletedCompleted: Bool = false
    
    static func == (lhs: OutfitContextCard, rhs: OutfitContextCard) -> Bool {
        return lhs.outfit.id == rhs.outfit.id &&
        lhs.outfit.name == rhs.outfit.name &&
        lhs.outfit.fullLookImagePath == rhs.outfit.fullLookImagePath &&
        lhs.subTitleAlert == rhs.subTitleAlert &&
        lhs.outfit.garments.count == rhs.outfit.garments.count
    }
    
    var body: some View {
        NavigationLink(value: self.outfit) {
            ModelCardView(
                title      : self.outfit.name,
                subheadline: self.subTitleAlert,
                imagePath  : self.outfit.fullLookImagePath
            )
            .opacity(self.subTitleAlert != nil ? 0.7 : 1)
            .contextMenu {
                self.contextMenuButtons(for: self.outfit)
            }
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.success, trigger: self.taskDeletedCompleted)
    }
    
    @ViewBuilder
    private func contextMenuButtons(for item: Outfit) -> some View {
        Button {
            self.selectedItem = item
        } label: {
            Label("Edit Details", systemImage: "pencil")
        }
        
        Button(role: .destructive) {
            self.manager?.delete(item)
            self.taskDeletedCompleted.toggle()
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }
}
