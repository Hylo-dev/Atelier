//
//  InventoryView.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 15/02/26.
//

import SwiftUI
import SwiftData

struct InventoryView: View {
    
    
    
    @Environment(\.modelContext)
    private var context
    
    
    
    // MARK: - Parameters Val
    
    @Bindable
    var manager: CaptureManager
    
    @Bindable
    var categoryState: TabFilterState
    
    var title: String
    
    
    
    // MARK: - Screen values
    
    @Query(
        sort : \Garment.name,
        order: .reverse
    )
    private var garments: [Garment]
    
    @State
    private var garmentManager: GarmentManager?
    
    @State
    private var groupedGarments: [String: [Garment]] = [:]
    
    
    
    // MARK: - Add Garment Sheet values
    
    @State
    private var isAddGarmentSheetVisible: Bool = false
    
    
    
    // MARK: - Modify Garment Sheet values
    
    @State
    private var selectedItem: Garment?
    
    
    
    // MARK: - Filter Garment Sheet values
    
    @State
    private var filter = FilterGarmentConfig()
    
    @State
    private var isFilterSheetVisible: Bool = false
    
    @State
    private var availableBrands: [String] = []
    
    
    
    // MARK: - Variables private
        
    @State
    private var visibleGarments: [Garment] = []
    
    
    
    // MARK: - Static property
    
    static private let columns = [
        GridItem(.adaptive(minimum: 150), spacing: 20)
    ]
    
    var body: some View {
//        let _ = Self._printChanges()
        
        Group {
            if self.garments.isEmpty {
                ContentUnavailableView(
                    "Closet Empty",
                    systemImage: "hanger",
                    description: Text("Time to fill this closet up")
                )
                .containerRelativeFrame(.vertical)
                
            } else {
                LiquidPagingView(
                    selection  : self.$categoryState.selection,
                    onProgressChange: { newVal in
                        if self.categoryState.progress != newVal {
                            self.categoryState.progress = newVal
                        }
                    },
                    items      : self.categoryState.items,
                    isEnabled  : self.categoryState.isVisible
                ) { category in
                    self.scrollableGrid(for: category)
                }
                .ignoresSafeArea(.container, edges: .top)
                
            }
        }
        .onAppear {
            if self.garmentManager == nil {
                self.garmentManager = GarmentManager(context: self.context)
            }
                        
            self.updateBrands()
            self.updateCategories()
            self.updateFilteredGarments()
        }
        .onChange(of: self.garments) {
            
            withAnimation {
                self.updateCategories()
            }
            
            self.updateBrands()
            self.updateFilteredGarments()
        }
        .onChange(of: self.filter) {
            self.updateFilteredGarments()
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
                Button("Add", systemImage: "plus") {
                    self.isAddGarmentSheetVisible = true
                }
            }
        }
        .navigationDestination(for: Garment.self) { selectedItem in
            InfoGarmentView(
                garmentManager: self.$garmentManager,
                item          : selectedItem
            )
            
        }
        .sheet(isPresented: self.$isAddGarmentSheetVisible) {
            NavigationStack {
                AddGarmentView(garmentManager: self.$garmentManager)
            }
        }
        .sheet(item: self.$selectedItem) { germent in
            
            NavigationStack {
                ModifyGarmentView(
                    garmentManager: self.$garmentManager,
                    garment       : germent
                )
            }
        }
        .sheet(isPresented: self.$isFilterSheetVisible) {
            FilterGarmentView(
                filters: self.$filter,
                brands : self.$availableBrands
            )
        }
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    private func scrollableGrid(for category: String) -> some View {
        ScrollView(.vertical) {
            
            LazyVGrid(columns: Self.columns, spacing: 20) {
                ForEach(self.groupedGarments[category] ?? [], id: \.id) { item in
                    
                    GarmentContextCard(
                        item        : item,
                        manager     : self.garmentManager,
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
    private func updateBrands() {
        let rawBrands = Set(self.garments.compactMap { $0.brand })
        let newBrands = rawBrands.sorted()
        
        if self.availableBrands != newBrands {
            print("Diff found: Updating brands pointer")
            self.availableBrands = newBrands
            
        } else { print("No changes in brands, skipping update to save cycles") }
    }
    
    
    
    @inline(__always)
    private func updateCategories() {
        let uniqueCategories = Set(self.garments.lazy.map {
            $0.category.title
        })
        let newCategories = ["All"] + uniqueCategories.sorted()
        
        if self.categoryState.items != newCategories {
            print("Diff found: Updating categories pointer")
            self.categoryState.items = newCategories
            
        } else {
            print("No changes in categories, skipping update to save cycles")
        }
    }
    
    
    @inline(__always)
    private func updateFilteredGarments() {
        self.visibleGarments = FilterGarmentConfig.filterGarments(
            allGarments: self.garments,
            config     : self.filter
        )
        
        var newGrouped: [String: [Garment]] = [:]
        newGrouped["All"] = self.visibleGarments
        
        let groupedByCategory = Dictionary(
            grouping: self.visibleGarments,
            by: { $0.category.title }
        )
        
        for (category, items) in groupedByCategory {
            newGrouped[category] = items
        }
        
        self.groupedGarments = newGrouped
    }
}

fileprivate
struct GarmentContextCard: View {
    let item   : Garment
    let manager: GarmentManager?
    
    @Binding
    var selectedItem: Garment?
    
    var body: some View {
        NavigationLink(value: item) {
            ModelCardView(
                title      : item.name,
                subheadline: item.brand,
                imagePath  : item.imagePath
            )
            .equatable()
            .id(item.id)
            .contextMenu {
                self.contextMenuButtons(for: item)
            }
        }
        .buttonStyle(.plain)
    }
    
    
    
    @ViewBuilder
    private func contextMenuButtons(for item: Garment) -> some View {
        let washingState = item.state == .toWash
        let loanState    = item.state == .onLoan
        
        Button {
            item.state = washingState ? .drying : .toWash
            self.manager?.updateGarment()
            
        } label: {
            Label(
                washingState ? "Mark as Clean" : "Move to Wash",
                systemImage: washingState ? "sparkle" : "washer.fill"
            )
        }
        .disabled(!item.state.readyToWash())
        
        Button {
            item.state = loanState ? .available : .onLoan
            self.manager?.updateGarment()
            
        } label: {
            Label(
                loanState ? "Mark as Returned" : "Mark as Lent",
                systemImage: loanState ? "arrow.uturn.backward" : "person.2"
            )
        }
        .disabled(!item.state.readyToLent())
        
        
        Divider()
        
        
        Button {
            
        } label: {
            Label("Add to Outfit", systemImage: "tshirt.fill")
        }
        
        
        Divider()
        
        
        Button {
            self.selectedItem = item
            
        } label: {
            Label("Edit Details", systemImage: "pencil")
        }
        
        Button(role: .destructive) {
            self.manager?.deleteGarment(item)
            
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }
}
