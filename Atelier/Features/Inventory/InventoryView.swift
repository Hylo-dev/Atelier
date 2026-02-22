//
//  InventoryView.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 15/02/26.
//

import SwiftUI
import SwiftData

struct InventoryView: View {
    
    @Bindable
    var manager: CaptureManager
    
    var title: String
        
    @Environment(\.modelContext)
    private var context
    
    @Query(
        sort : \Garment.name,
        order: .reverse
    )
    private var garments: [Garment]
    
    @State
    private var garmentManager: GarmentManager?
    
    @State
    private var searchText: String = ""
    
    
    // MARK: - Garment Sheet property
    
    @State
    private var showGarmentSheet: Bool = false
    
    @State
    private var selectedItem: Garment?
    
    // MARK: - Filter Sheet property
    
    @State
    private var filter = FilterGarmentConfig()
    
    @State
    private var showFilterSheet: Bool = false
    
    @State
    private var availableBrands: [String] = []
    
    @Binding
    var selectedCategory: String?
    
    @Binding
    var tabProgress: CGFloat
    
    @Binding
    var availableCategories: [String]
        
    var visibleGarments: [Garment] {
        return FilterGarmentConfig.filterGarments(
            allGarments: self.garments,
            config     : self.filter
        )
    }
    
    var filteredModels: [Garment] {
        return if self.searchText.isEmpty {
            self.visibleGarments
            
        } else {
            self.visibleGarments.filter {
                $0.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    // MARK: - Static property
    
    static private let columns = [
        GridItem(.adaptive(minimum: 150), spacing: 20)
    ]
    
    var body: some View {
        
        ZStack {
            if self.garments.isEmpty {
                ContentUnavailableView(
                    "Closet Empty",
                    systemImage: "hanger",
                    description: Text("Time to fill this closet up")
                )
                .containerRelativeFrame(.vertical)
                
            } else {
                LiquidPagingView(
                    selection  : self.$selectedCategory,
                    tabProgress: self.$tabProgress,
                    items      : self.availableCategories
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
            self.updateBrands()
            self.updateCategories()
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
                    self.showFilterSheet = true
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button("Add", systemImage: "plus") {
                    self.showGarmentSheet = true
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
            isPresented:   self.$showGarmentSheet,
            onDismiss  : { self.showGarmentSheet = false }
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
        .sheet(isPresented: self.$showFilterSheet) {
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
                                withAnimation {
                                    self.garmentManager?.deleteGarment(item)
                                }
                                
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
        .scrollClipDisabled()

    }
    
    private func items(for category: String) -> [Garment] {
        return if category == "All" {
            self.filteredModels
        } else {
            self.filteredModels.filter { $0.category.label == category }
        }
    }
    
    // MARK: - Handlers
    
    @inline(__always)
    private func updateBrands() {
        let rawBrands = self.garments.lazy.compactMap { $0.brand }
        let newBrands = Array(Set(rawBrands)).sorted()
        
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
        
        if self.availableCategories != newCategories {
            print("Diff found: Updating categories pointer")
            self.availableCategories = newCategories
            
        } else {
            print("No changes in categories, skipping update to save cycles")
        }
    }
}
