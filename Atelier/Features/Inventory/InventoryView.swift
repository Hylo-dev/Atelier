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
    
    @Environment(GarmentManager.self)
    private var garmentManager: GarmentManager
    
    @Environment(ApplianceManager.self)
    private var applianceManager: ApplianceManager
    
    
    
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
    
    @Query(
        sort : \LaundrySession.dateCreated,
        order: .forward
    )
    private var laundrySessions: [LaundrySession]
        
    
    // MARK: - Add Garment Sheet values
    
    @State
    private var isAddGarmentSheetVisible: Bool = false
    
    
    
    // MARK: - Modify Garment Sheet values
    
    @State
    private var selectedItem: Garment?
    
    @State
    private var navigatedGarment: Garment?
    
    
    
    // MARK: - Filter Garment Sheet values
    
    @State
    private var filter = FilterGarmentConfig()
    
    @State
    private var isFilterSheetVisible: Bool = false
    
    
    
    // MARK: - Static property
    
    static private let columns = [
        GridItem(.adaptive(minimum: 150), spacing: 20)
    ]
    
    
    
    var body: some View {
        let _ = Self._printChanges()
        
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
        .onChange(of: garments) {
            updateData()
        }
        .onChange(of: filter) {
            updateData()
        }
        .onAppear {
            updateData()
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
        .navigationDestination(item: $navigatedGarment) { item in
            InfoGarmentView(item)
                .onAppear {
                    withAnimation {
                        categoryState.subSection = true
                    }
                }
        }
        .onChange(of: navigatedGarment) { old, newValue in
            if newValue == nil {
                withAnimation {
                    categoryState.subSection = false
                }
            }
        }
        .sheet(isPresented: self.$isAddGarmentSheetVisible) {
            NavigationStack {
                GarmentEditorView()
            }
        }
        .sheet(item: self.$selectedItem) { germent in
            NavigationStack {
                GarmentEditorView(garment: germent)
            }
        }
        .sheet(isPresented: self.$isFilterSheetVisible) {
            FilterGarmentView(
                filters: self.$filter,
                brands : garmentManager.availableBrands
            )
        }
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    private func scrollableGrid(for category: String) -> some View {
        ScrollView(.vertical) {
            
            LazyVGrid(columns: Self.columns, spacing: 20) {
                ForEach(garmentManager.groupedGarments[category] ?? [], id: \.id) { item in
                    
                    GarmentContextCard(
                        item            : item,
                        sessions        : laundrySessions,
                        manager         : garmentManager,
                        applianceManager: applianceManager,
                        selectedItem    : $selectedItem,
                        navigatedGarment: $navigatedGarment
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
        garmentManager.processGarments(garments, with: filter)
        
        if self.categoryState.items != garmentManager.availableCategories {
            self.categoryState.items = garmentManager.availableCategories
        }
    }
}

fileprivate
struct GarmentContextCard: View, Equatable {
    let item            : Garment
    let sessions        : [LaundrySession]
    let manager         : GarmentManager
    let applianceManager: ApplianceManager
    
    
    @Binding
    var selectedItem: Garment?
    
    @Binding
    var navigatedGarment: Garment?
    
    @State
    private var didTriggerDelete: Bool = false
    
    static func == (lhs: GarmentContextCard, rhs: GarmentContextCard) -> Bool {
        guard !lhs.item.isDeleted && !rhs.item.isDeleted else {
            return lhs.item.id == rhs.item.id
        }
        
        return lhs.item.id == rhs.item.id &&
        lhs.item.name == rhs.item.name &&
        lhs.item.brand == rhs.item.brand &&
        lhs.item.imagePath == rhs.item.imagePath &&
        lhs.item.state == rhs.item.state
    }
    
    var body: some View {
        Button {
            navigatedGarment = item
        } label: {
            ModelCardView(
                title: self.item.name,
                subheadline: self.item.brand,
                imagePath: self.item.imagePath
            )
            .contextMenu {
                self.contextMenuButtons(for: self.item)
            }
        }
        .sensoryFeedback(.success, trigger: didTriggerDelete)
        .buttonStyle(.plain)
    }
    
    
    
    @ViewBuilder
    private func contextMenuButtons(for item: Garment) -> some View {
        let loanState = item.state == .onLoan
        let isToWash  = item.state == .toWash
        
        Button {
            if isToWash {
                manager.resetWear(
                    for : item,
                    used: applianceManager
                )
                
            } else {
                manager.setWashState(
                    for : item,
                    in  : sessions,
                    used: applianceManager
                )
            }
            
        } label: {
            Label(
                isToWash ? "Mark as Clean" : "Move to Wash",
                systemImage: isToWash ? "sparkle" : "washer"
            )
        }
//        .disabled(!item.state.readyToWash)
        
        Button {
            item.state = loanState ? .available : .onLoan
            self.manager.update()
            
        } label: {
            Label(
                loanState ? "Mark as Returned" : "Mark as Lent",
                systemImage: loanState ? "arrow.uturn.backward" : "person.2"
            )
        }
        .disabled(!item.state.readyToLent)
        
        
        
        Divider()
        
        
        
        Button {
            manager.logWear(
                for : item,
                in  : sessions,
                used: applianceManager
            )
            
        } label: {
            Label("Log wear", systemImage: "checkmark.seal")
        }
        
        
        Button {
            
        } label: {
            Label("Add to Outfit", systemImage: "tshirt")
        }
        
        
        
        Divider()
        
        
        
        Button {
            self.selectedItem = item
            
        } label: {
            Label("Edit Details", systemImage: "pencil")
        }
        
        Button(role: .destructive) {
            didTriggerDelete.toggle()
            manager.delete(item)
            
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }
}
