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
    
    @Binding
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
    
    
    
    // MARK: - Computed variables
        
    var visibleGarments: [Garment] {
        return FilterGarmentConfig.filterGarments(
            allGarments: self.garments,
            config     : self.filter
        )
    }
    
    // MARK: - Static property
    
    static private let columns = [
        GridItem(.adaptive(minimum: 150), spacing: 20)
    ]
    
    var body: some View {
        
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
                    tabProgress: self.$categoryState.progress,
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
        }
        .onChange(of: self.garments) {
            
            withAnimation {
                self.updateBrands()
                self.updateCategories()
            }
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
        .sheet(
            isPresented:   self.$isAddGarmentSheetVisible,
            onDismiss  : { self.isAddGarmentSheetVisible = false }
        ) {
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
            FilterSheetView(
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
                ForEach(self.items(for: category), id: \.id) { item in
                    
                    NavigationLink(value: item) {
                        ModelCardView(
                            title      : item.name,
                            subheadline: item.brand,
                            imagePath  : item.imagePath
                        )
                        .id(item.id)
                        .contextMenu {
                            self.contextMenuButtons(for: item)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
        }
        .contentMargins(.top, 150, for: .scrollContent)
        .scrollIndicators(.hidden)
        .scrollClipDisabled()

    }
    
    @ViewBuilder
    private func contextMenuButtons(for item: Garment) -> some View {
        let washingState = item.state == .toWash
        let loanState    = item.state == .onLoan
        
        Button {
            item.state = washingState ? .drying : .toWash
            self.garmentManager?.updateGarment()
            
        } label: {
            Label(
                washingState ? "Mark as Clean" : "Move to Wash",
                systemImage: washingState ? "sparkle" : "washer.fill"
            )
        }
        .disabled(!item.state.readyToWash())
        
        Button {
            item.state = loanState ? .available : .onLoan
            self.garmentManager?.updateGarment()
            
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
            self.garmentManager?.deleteGarment(item)
            
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }
    
    
    
    // MARK: - Handlers
    
    private func items(for category: String) -> [Garment] {
        return if category == "All" {
            self.visibleGarments
            
        } else {
            self.visibleGarments.filter { $0.category.label == category }
        }
    }
    
    
    
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
        let uniqueCategories = Set(garments.lazy.map {
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
}
