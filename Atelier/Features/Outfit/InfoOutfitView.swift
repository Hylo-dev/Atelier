//
//  InfoGarmentView.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 24/02/26.
//


import SwiftUI

struct InfoOutfitView: View {
    
    
    
    // MARK: - Parameters Variables
    
    let outfit: Outfit
    
    
    
    // MARK: - Private State Variables
    
    @Environment(\.dismiss)
    private var dismiss
    
    @Environment(OutfitManager.self)
    private var outfitManager: OutfitManager
    
    @State
    private var isModifySheetVisible: Bool
    
    @State
    private var deleteItem: Bool
    
    @State
    private var isDeleted: Bool
    
    
    init(_ outfit: Outfit) {
        self.outfit = outfit
        
        self.isModifySheetVisible = false
        self.deleteItem           = false
        self.isDeleted            = false
    }
    
    
    
    var body: some View {
        
        HeroListView(outfit.fullLookImagePath) {
            titleSection
            
        } content: {
            self.sectionCare
            
            self.sectionStyleAndCategory
            
            if !outfit.garments.isEmpty {
                garmentsLazyRow
            }
        }
        .sensoryFeedback(.success, trigger: isDeleted)
        .toolbar {
            
            ToolbarItem {
                Button(role: .destructive) {
                    self.deleteItem = true
                    
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
                        
            ToolbarItem {
                Button {
                    self.isModifySheetVisible = true
                    
                } label: {
                    Label("Edit", systemImage: "pencil")
                }
            }
        }
        .sheet(
            isPresented: self.$isModifySheetVisible,
            onDismiss: { self.isModifySheetVisible = false }
        ) {
            NavigationStack {
                OutfitEditorView(outfit)
            }
        }
        .alert(
            "Delete Garment?",
            isPresented: self.$deleteItem
        ) {
            
            Button("Delete", role: .destructive) {
                withAnimation {
                    outfitManager.delete(self.outfit)
                    isDeleted.toggle()
                }
                
                dismiss()
            }
            
        } message: {
            Text("Are you sure? This action cannot be undone.")
        }
    }
    
    
    
    // MARK: - Views

    
    
    @ViewBuilder
    private var titleSection: some View {
        VStack(spacing: 3) {
            Text(self.outfit.name)
                .font(.system(size: 65))
                .fontWeight(.bold)
                .fontDesign(.default)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
            
            if let date = self.outfit.lastWornDate {
                Text("Last worn - \(date.formatted(date: .abbreviated, time: .omitted))")
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                    .fontDesign(.rounded)
            }
            
            
        }
        .frame(maxWidth: .infinity)
    }
    
    
    
    @ViewBuilder
    private var sectionCare: some View {
        SectionList(titleKey: "Care & Usage") {
            
            RowInfoView(
                title: "Availability",
                value: self.outfit.stateWear
            )
            
            
            if self.outfit.missingItemsCount > 0 {
                RowInfoView(
                    title: "Missing garments",
                    value: outfit.missingItemsCount <= 1 ? "\(outfit.missingItemsCount) piece" : "\(outfit.missingItemsCount) pieces"
                )
            }
            
            
            if self.outfit.wearCount > 0 {
                RowInfoView(
                    title: "Wear Count",
                    value: "\(self.outfit.wearCount) times"
                )
            }
        }
    }
    
    
    @ViewBuilder
    private var sectionStyleAndCategory: some View {
        SectionList(titleKey: "Details") {
            
            RowInfoView(title: "Season", value: self.outfit.season.rawValue)
            RowInfoView(title: "Style", value: self.outfit.style.rawValue)
        }
    }
    
    
    
    @ViewBuilder
    private var garmentsLazyRow: some View {
        SectionList(titleKey: "Items") {
            
            ScrollView(.horizontal) {
                LazyHStack(spacing: 15) {
                    ForEach(self.outfit.garments, id: \.id) { garment in
                        
                        ModelCardView(
                            title    : garment.name,
                            imagePath: garment.imagePath
                        )
                        .frame(width: 150, height: 250)
                        
                    }
                }
            }
        }
        .padding(.vertical, 10)
    }
    
    
    // TODO: Calc weight color for each garment  
    @ViewBuilder
    private var outfitColors: some View {
        
        HStack {
            
            ForEach(outfit.garments, id: \.id) { color in
                
                VStack {
                    
                    Text(color.color)
                }
                
            }
            
        }
        
    }
}
