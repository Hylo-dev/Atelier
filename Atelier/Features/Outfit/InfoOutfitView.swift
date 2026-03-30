//
//  InfoGarmentView.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 24/02/26.
//


import SwiftUI
import Glur

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
            sectionColors
            
            sectionCare
            
            sectionDetails
            
            if outfit.notes != nil {
                sectionNotes
            }
            
            if !outfit.garments.isEmpty {
                garmentsLazyRow
            }
        }
        .sensoryFeedback(.success, trigger: isDeleted)
        .toolbar {
            
            ToolbarItem {
                Button {
                    outfit.isFavorite.toggle()
                    
                } label: {
                    Label(
                        "Is Favorite",
                        systemImage: outfit.isFavorite ? "star.fill" : "star"
                    )
                }
//                .tint(.yellow) // Not sure
            }
            
            ToolbarSpacer()
            
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
            
            let date = outfit.creationDate
            Text("Created - \(date.formatted(date: .abbreviated, time: .omitted))")
                .font(.headline)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
                .fontDesign(.rounded)
            
            
        }
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    private var sectionColors: some View {
        
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 16) {
                ForEach(outfit.colors, id: \.self) { color in
                    VStack(alignment: .leading) {
                        Spacer()
                        Text("#\(color)")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .fontDesign(.monospaced)
                            .foregroundColor(.primary)
                            .padding(13)
                    }
                    .frame(width: 120, height: 87, alignment: .leading)
                    .background(Color(hex: color))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }
        }
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
    private var sectionDetails: some View {
        SectionList(titleKey: "Details") {
            
            RowInfoView(
                title: "Total Value",
                value: outfit.totalValue.formatted(
                    .currency(
                        code: Locale.current.currency?.identifier ?? "EUR"
                    )
                )
            )
            
            if let date = outfit.lastWornDate {
                RowInfoView(
                    title: "Last Worn",
                    value: date.formatted(date: .abbreviated, time: .omitted)
                )
            }
            
            RowInfoView(title: "Season", value: self.outfit.season.rawValue)
                        
            VStack(alignment: .leading, spacing: 5) {
                Text("Occasions")
                    .foregroundStyle(.secondary)
                
                ScrollView(.horizontal) {
                    LazyHStack(spacing: 5) {
                        ForEach(outfit.occasion) { val in
                            
                            Text(val.rawValue)
                                .font(.subheadline)
                                .fontDesign(.rounded)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 7)
                                .glassEffect()
                            
                        }
                    }
                }
            }
            .padding(.vertical, 13)
            
        }
    }
    
    
    @ViewBuilder
    private var sectionNotes: some View {
        SectionList(titleKey: "Notes") {
            VStack(alignment: .leading) {
                Text(outfit.notes!)
                .font(.body)
                .fontWeight(.regular)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 10)
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
