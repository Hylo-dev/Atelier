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
        
        ScrollView {
            if self.garments.isEmpty {
                ContentUnavailableView(
                    "Closet Empty",
                    systemImage: "hanger",
                    description: Text("Time to fill this closet up")
                )
                .containerRelativeFrame(.vertical)
                
            } else { self.modelGridView }
        }
        .contentMargins(.horizontal, 16, for: .scrollContent)
        .onAppear {
            if self.garmentManager == nil {
                self.garmentManager = GarmentManager(context: self.context)
            }
        }
        .searchable(
            text     : self.$searchText,
            prompt   : "Search garment"
        )
        .toolbar {
            
            ToolbarItem(placement: .topBarTrailing) {
                Button("Add", systemImage: "plus") {
                    self.showGarmentSheet = true
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button("Filter", systemImage: "line.3.horizontal.decrease") {
                    self.showFilterSheet = true
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                
                Menu {
                    
                    Button {
                        print("Name Order")
                        
                    } label: {
                        Label("Name", systemImage: "textformat.alt")
                    }
                    
                } label: {
                    Image(systemName: "ellipsis")
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
                brands : Array(Set(self.garments.lazy.compactMap { $0.brand }))
            )
        }
    }
    
    // MARK: - Subviews
    
    private var modelGridView: some View {
        LazyVGrid(columns: Self.columns, spacing: 20) {
            
            ForEach(self.filteredModels, id: \.id) { item in
                
                NavigationLink(value: item) {
                    ModelCardView(
                        title      : item.name,
                        subheadline: item.brand ?? " ",
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
    }
}
