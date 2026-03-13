//
//  InfoGarmentView.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 24/02/26.
//


import SwiftUI

struct InfoOutfitView: View {
    
    
    
    // MARK: - Parameters Variables
        
    @Binding
    var manager: OutfitManager?
    
    let outfit: Outfit
    
    
    
    // MARK: - Private State Variables
    
    @Environment(\.dismiss)
    private var dismiss
    
    @State
    private var isModifySheetVisible: Bool = false
    
    @State
    private var deleteItem: Bool = false
    
    @State
    private var isDeleted: Bool = false
    
    
    
    var body: some View {
        
        HeroListView(outfit.fullLookImagePath) {
            titleSection
            
        } content: {
            self.sectionCare
            
            self.sectionStyleAndCategory
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
                OutfitEditorView(
                    outfitManager: self.$manager,
                    outfit       : self.outfit
                )
            }
        }
        .alert(
            "Delete Garment?",
            isPresented: self.$deleteItem
        ) {
            
            Button("Delete", role: .destructive) {
                withAnimation {
                    self.manager?.delete(self.outfit)
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
                title: "Wear availability",
                value: self.outfit.stateWear
            )
            
            
            if self.outfit.missingItemsCount > 0 {
                RowInfoView(
                    title: "Missing garments",
                    value: "\(self.outfit.missingItemsCount) pieces"
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
            
            self.garmentsLazyRow
        }
    }
    
    
    
    @ViewBuilder
    private var garmentsLazyRow: some View {
        VStack(alignment: .leading) {
            
            Text("Garments")
                .fontWeight(.medium)
                .fontDesign(.rounded)
                .foregroundStyle(.secondary)
            
            
            ScrollView(.horizontal) {
                LazyHStack {
                    ForEach(self.outfit.garments, id: \.id) { garment in
                        
                        ModelCardView(
                            title    : garment.name,
                            imagePath: garment.imagePath
                        )
                        .equatable()
                        .frame(width: 150, height: 150)
                        
                    }
                }
            }
        }
        .padding(.vertical, 10)
    }
}
