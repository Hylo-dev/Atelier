//
//  InventoryView.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 15/02/26.
//

import SwiftUI
import SwiftData

struct WardrobeView: View {
        
    @Environment(\.modelContext)
    private var context
    
    
    @Environment(GarmentManager.self)
    private var garmentManager
    
    @Environment(ApplianceManager.self)
    private var applianceManager
        
    @Environment(CaptureManager.self)
    private var manager
    
    
    @Query(
        sort : \Garment.name,
        order: .reverse
    )
    private var garments: [Garment]
    
    
    // MARK: - Parameters Val
    
    @Bindable
    var wardrobeState: TabFilterService
    
    @State
    private var wardrobeViewModel: WardrobeViewModel

    
    // MARK: - Static property
    
    static private let columns = [
        GridItem(.adaptive(minimum: 150), spacing: 20)
    ]
    
    
    init(
        title        : String,
        wardrobeState: TabFilterService
    ) {
        self._wardrobeViewModel = State(initialValue: WardrobeViewModel(title: title))
        self.wardrobeState     = wardrobeState
    }
    
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
                    selection: $wardrobeState.selection,
                    onProgressChange: { newVal in
                        if wardrobeState.progress != newVal {
                            wardrobeState.progress = newVal
                        }
                    },
                    items    : wardrobeState.items,
                    isEnabled: wardrobeState.isPagesEnabled
                ) { category in
                    scrollableGrid(for: category)
                }
                .ignoresSafeArea(.container, edges: .top)
                
            }
        }
        .onChange(of: garments, initial: true) {
            wardrobeViewModel.updateData(
                garments,
                wardrobeState: wardrobeState,
                service: garmentManager
            )
        }
        .onChange(of: wardrobeViewModel.filter.isFiltering) {
            wardrobeViewModel.updateData(
                garments,
                wardrobeState: wardrobeState,
                service: garmentManager
            )
        }
        .onChange(of: wardrobeViewModel.filter.isFiltering) { _, newValue in
            wardrobeState.hiddenSectionBar = newValue
        }
        .toolbar {
            ToolbarItem(placement: .title) {
                Text(String(repeating: " ", count: 150))
                    .overlay(alignment: .leading) {
                        Text(wardrobeViewModel.title)
                            .font(.title)
                            .fontWeight(.bold)
                    }
            }
            
            if !garments.isEmpty {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Filter", systemImage: "line.3.horizontal.decrease") {
                        wardrobeViewModel.isFilterSheetVisible = true
                    }
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button("Add", systemImage: "plus") {
                    wardrobeViewModel.isAddGarmentSheetVisible = true
                }
            }
        }
        .navigationDestination(item: $wardrobeViewModel.navigatedGarment) { item in
            InfoGarmentView(item)
                .onAppear {
                    withAnimation {
                        wardrobeState.hiddenSectionBar = true
                    }
                }
        }
        .onChange(of: wardrobeViewModel.navigatedGarment) { old, newValue in
            if newValue == nil {
                withAnimation {
                    wardrobeState.hiddenSectionBar = false
                }
            }
        }
        .sheet(isPresented: $wardrobeViewModel.isAddGarmentSheetVisible) {
            NavigationStack {
                GarmentEditorView()
            }
        }
        .sheet(item: $wardrobeViewModel.selectedItem) { germent in
            NavigationStack {
                GarmentEditorView(garment: germent)
            }
        }
        .sheet(isPresented: $wardrobeViewModel.isFilterSheetVisible) {
            FilterGarmentView(
                filters: $wardrobeViewModel.filter,
                brands : garmentManager.availableBrands
            )
        }
        .alert(
            wardrobeViewModel.alertManager.title,
            isPresented: $wardrobeViewModel.alertManager.isPresent
        ) {
            
        } message: {
            Text(wardrobeViewModel.alertManager.message)
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
                        selectedItem    : $wardrobeViewModel.selectedItem,
                        navigatedGarment: $wardrobeViewModel.navigatedGarment
                        
                    ) { title, message in
                        wardrobeViewModel.alertManager.title     = title
                        wardrobeViewModel.alertManager.message   = message
                        wardrobeViewModel.alertManager.isPresent = true
                    }
                    .id(item.id)
                }
            }
            .padding(.horizontal, 16)
        }
        .contentMargins(.top, 150, for: .scrollContent)
        .scrollIndicators(.hidden)

    }
}
