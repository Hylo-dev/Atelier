//
//  OutfitView.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 17/02/26.
//

import SwiftUI
import SwiftData

struct OutfitView: View {
    
    @Bindable
    var manager: CaptureManager
    
    @Environment(\.modelContext)
    private var context
    
    @Query(
        sort : \Outfit.lastWornDate,
        order: .forward
    )
    private var outfits: [Outfit]
    
    @State
    private var outfitManager: OutfitManager?
    
    
    @State
    private var searchText: String = ""
    
    
    // MARK: - Sheet property
    
    @State
    private var isAddOutfitSheetVisible: Bool = false
    
    
    static private let columns = [
        GridItem(.adaptive(minimum: 150), spacing: 20)
    ]
    
    var body: some View {
        
        ScrollView {
            if self.outfits.isEmpty {
                ContentUnavailableView(
                    "Outfits Empty",
                    systemImage: "tshirt",
                    description: Text("Time to create your drip")
                )
                .containerRelativeFrame(.vertical)
                
            } else { self.modelGridView }
        }
        .contentMargins(.horizontal, 16, for: .scrollContent)
        .onAppear {
            if self.outfitManager == nil {
                self.outfitManager = OutfitManager(context: self.context)
            }
        }
        .searchable(
            text  : self.$searchText,
            prompt: "Search outfit"
        )
        .toolbar {
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
    
    private var modelGridView: some View {
        LazyVGrid(columns: Self.columns, spacing: 20) {
            
            ForEach(self.filteredModels, id: \.id) { item in
                
                NavigationLink(value: item) {
                    ModelCardView(
                        title      : item.name,
                        subheadline: item.style.rawValue,
                        imagePath  : item.fullLookImagePath
                    )
                    .contextMenu {
                        
                        Button {
                            // self.selectedItem = item
                            
                        } label: {
                            Label("Edit Details", systemImage: "pencil")
                        }
                        
                        Button {
                            withAnimation {
                                self.outfitManager?.deleteOutfit(item)
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
    
    // MARK: - Logic
    
    var filteredModels: [Outfit] {
        return if self.searchText.isEmpty {
            self.outfits
            
        } else {
            self.outfits.filter {
                $0.name.localizedCaseInsensitiveContains(self.searchText)
            }
        }
    }
}
