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
    
    
    @State
    private var alertManager = AlertManager()
    
    
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
                    items    : self.categoryState.items,
                    isEnabled: self.categoryState.isPagesEnabled
                ) { category in
                    scrollableGrid(for: category)
                }
                .ignoresSafeArea(.container, edges: .top)
                
            }
        }
        .onChange(of: garments, initial: true) {
            updateData()
        }
        .onChange(of: filter) {
            updateData()
        }
        .onChange(of: filter.isFiltering) { _, newValue in
            categoryState.hiddenSectionBar = newValue
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
            
            if !garments.isEmpty {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Filter", systemImage: "line.3.horizontal.decrease") {
                        self.isFilterSheetVisible = true
                    }
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
                        categoryState.hiddenSectionBar = true
                    }
                }
        }
        .onChange(of: navigatedGarment) { old, newValue in
            if newValue == nil {
                withAnimation {
                    categoryState.hiddenSectionBar = false
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
                filters: $filter,
                brands : garmentManager.availableBrands
            )
        }
        .alert(
            alertManager.title,
            isPresented: $alertManager.isPresent
        ) {
            
        } message: {
            Text(alertManager.message)
        }
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    private func scrollableGrid(for category: String) -> some View {
        ScrollView(.vertical) {
            
            LazyVGrid(columns: Self.columns, spacing: 20) {
                let items = garmentManager.groupedGarments[category] ?? []
                
                ForEach(items, id: \.id) { item in
                    
                    GarmentContextCard(
                        item            : item,
                        manager         : garmentManager,
                        processGarment  : applianceManager,
                        selectedItem    : $selectedItem,
                        navigatedGarment: $navigatedGarment
                        
                    ) { title, message in
                        alertManager.title     = title
                        alertManager.message   = message
                        alertManager.isPresent = true
                    }
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
        print("Updated data Garment View")
        garmentManager.processGarments(garments, with: filter)
        
        if self.categoryState.items != garmentManager.availableCategories {
            self.categoryState.items = garmentManager.availableCategories
        }
    }
}


fileprivate
struct GarmentContextCard: View {
    
    var item            : Garment
    let manager         : GarmentManager
    let applianceManager: ApplianceProcessGarmentProtocol
    let onError         : (String, String) -> Void
    
    @Binding
    var selectedItem: Garment?
    
    @Binding
    var navigatedGarment: Garment?
    
    @State
    private var didTriggerDelete: Bool = false
    
    init(
        item: Garment,
        manager: GarmentManager,
        processGarment: ApplianceProcessGarmentProtocol,
        selectedItem: Binding<Garment?>,
        navigatedGarment: Binding<Garment?>,
        onError: @escaping (String, String) -> Void
    ) {
        self.item              = item
        self.manager           = manager
        self.applianceManager  = processGarment
        self.onError           = onError
        self._selectedItem     = selectedItem
        self._navigatedGarment = navigatedGarment
        self.didTriggerDelete  = didTriggerDelete
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
        }
        .buttonStyle(.plain)
        .contextMenu {
            let isToWash  = item.isToWash
            let loanState = item.state == .onLoan
            
            Text(item.name)
            
            Button {
                let title: String
                
                do {
                    if isToWash {
                        title = "Error on reset wear"
                        try manager.resetWear(
                            for : item,
                            used: applianceManager
                        )
                        
                    } else {
                        title = "Error on set state"
                        try manager.setWashState(
                            for : item,
                            used: applianceManager
                        )
                    }
                } catch {
                    onError(
                        title,
                        error.localizedDescription
                    )
                }
                
                
            } label: {
                Label(
                    isToWash ? "Mark as Clean" : "Move to Wash",
                    systemImage: isToWash ? "sparkle" : "washer"
                )
            }
            //        .disabled(!item.state.readyToWash)
            //
            Button {
                item.state = loanState ? .available : .onLoan
                do {
                    try manager.update()
                } catch {
                    onError(
                        "Error on update data",
                        error.localizedDescription
                    )
                }
                
            } label: {
                Label(
                    loanState ? "Mark as Returned" : "Mark as Lent",
                    systemImage: loanState ? "arrow.uturn.backward" : "person.2"
                )
            }
            .disabled(!item.state.readyToLent)
            
            
            
            Divider()
            
            
            
            Button {
                do {
                    let needWashing = manager.logWear(for: item)
                    
                    if needWashing {
                        try applianceManager.processUnassignedGarments([item])
                    }
                    
                } catch {
                    onError(
                        "Error on loggin wear",
                        error.localizedDescription
                    )
                }
                
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
                
                do {
                    try manager.delete(item)
                    
                } catch {
                    onError(
                        "Error on deleted data",
                        error.localizedDescription
                    )
                }
                
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .sensoryFeedback(.success, trigger: didTriggerDelete)
        .id(item.id)
    }
}
