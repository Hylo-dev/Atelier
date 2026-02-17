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
        sort : \Garment.lastWashingDate,
        order: .reverse
    )
    private var garments: [Garment]
    
    @State
    private var garmentManager: GarmentManager?
    
    @State
    private var searchText: String = ""
    
    // MARK: - Sheet property
    
    @State
    private var isAddGarmentSheetVisible: Bool = false
    
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
            text  : self.$searchText,
            prompt: "Search garment"
        )
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Add", systemImage: "plus") { self.isAddGarmentSheetVisible = true }
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
        
    }
    
    // MARK: - Subviews
    
    private var modelGridView: some View {
        LazyVGrid(columns: Self.columns, spacing: 20) {
            
            ForEach(self.filteredModels, id: \.self) { item in
                
                NavigationLink(value: item) {
                    ModelCard(item)
                        .contextMenu {
                            Button {
                                deleteModel(item)
                            } label: {
                                Label("Delete", systemImage: "trash.fill")
                            }
                            
                            Button {
                                
                            } label: {
                                Label("Modify", systemImage: "pencil")
                            }
                        }
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    // MARK: - Logic
    
    var filteredModels: [Garment] {
        return if self.searchText.isEmpty {
            self.garments
            
        } else {
            self.garments.filter {
                $0.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    private func deleteModel(_ item: Garment) {
        withAnimation {
            self.garmentManager?.deleteGarment(item)
        }
    }
}
