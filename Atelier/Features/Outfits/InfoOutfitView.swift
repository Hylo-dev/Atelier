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
    
    @State
    private var containerWidth: CGFloat = 0
    
    
    init(_ outfit: Outfit) {
        self.outfit = outfit
        
        self.isModifySheetVisible = false
        self.deleteItem           = false
        self.isDeleted            = false
    }
    
    
    
    var body: some View {
        
        HeroListView(
            outfit.fullLookImagePath,
            colorPlaceholder: outfit.colors.map { $0.toColor() },
            placeholderGradient: true
        ) {
            titleSection
            
        } content: {
            sectionPalette
            
            sectionDetails
            
            sectionUsage
            
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
                        "Favorite",
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
        .alert("Delete Outfit?", isPresented: $deleteItem) {
            Button("Delete", role: .destructive) {
                do {
                    try outfitManager.delete(outfit)
                } catch {
                    print(error.localizedDescription) // TODO: Manage error
                }
                dismiss()
            }
            
            Button("Cancel", role: .cancel) { }
            
        } message: {
            Text("Are you sure you want to delete '\(outfit.name)'? This action cannot be undone.")
        }
    }
    
    
    
    // MARK: - Views

    
    
    @ViewBuilder
    private var titleSection: some View {
        VStack(spacing: 4) {
            Text(self.outfit.name)
                .font(.system(size: 65))
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text("Added \(outfit.creationDate.formatted(date: .long, time: .omitted))")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
        }
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    private var sectionPalette: some View {
        
        let spacing = 10.0
        HStack(spacing: spacing) {
            ForEach(outfit.colors, id: \.id) { color in
                let totalSpacing = spacing * CGFloat(
                    max(0, outfit.colors.count - 1)
                )
                let relativeWidth = max(0, (containerWidth - totalSpacing) * CGFloat(color.weight) / 100.0)
                
                VStack(alignment: .leading) {
                    
                    HStack {
                        Spacer()
                        
                        Text("\(Int(color.weight))%")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .fontDesign(.monospaced)
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    HStack {
                        Text("#\(color.id)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .fontDesign(.monospaced)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.subheadline)
                            .fontWeight(.regular)
                            .foregroundColor(.primary)
                    }
                }
                .padding(13)
                .frame(width: relativeWidth, height: 90)
                .background(Color(hex: color.id))
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
        .frame(maxWidth: .infinity)
        .onGeometryChange(for: CGFloat.self) { proxy in
            proxy.size.width
        } action: { newValue in
            containerWidth = newValue
        }
    }
    
    
    @ViewBuilder
    private var sectionUsage: some View {
        SectionList(titleKey: "Usage") {
            
            RowInfoView(
                title: "Status",
                value: self.outfit.stateWear
            )
            
            
            if let date = outfit.lastWornDate {
                RowInfoView(
                    title: "Last Worn",
                    value: date.formatted(.dateTime.day().month().year())
                )
            }
            
            
            if self.outfit.wearCount > 0 {
                RowInfoView(
                    title: "Times Worn",
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
            
            RowInfoView(title: "Season", value: self.outfit.season.rawValue)
            
            RowInfoView(
                title: "Tone",
                value: outfit.tone.rawValue
            )
                        
            VStack(alignment: .leading, spacing: 13) {
                Text("Occasions")
                    .foregroundStyle(.secondary)
                
                ScrollView(.horizontal) {
                    LazyHStack(spacing: 8) {
                        ForEach(outfit.occasion) { val in
                            
                            Text(val.rawValue)
                                .font(.subheadline)
                                .fontDesign(.rounded)
                                .padding(.horizontal, 13)
                                .padding(.vertical, 8)
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
                            title      : garment.name,
                            subheadline: garment.subCategory.rawValue,
                            imagePath  : garment.imagePath
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
