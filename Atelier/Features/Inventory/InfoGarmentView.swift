//
//  InfoGarmentView.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 16/02/26.
//

import SwiftUI
import SwiftData

struct InfoGarmentView: View {
    
    
    
    // MARK: - Parameters Variables
    
    let item: Garment
    
    
    
    // MARK: - Private State Variables
    
    @Environment(\.dismiss)
    private var dismiss
    
    @Environment(GarmentManager.self)
    var garmentManager: GarmentManager
    
    @Environment(ApplianceManager.self)
    var applianceManager: ApplianceManager
    
    
    @Query
    private var outfits: [Outfit]
    
    
    @State
    private var isModifySheetVisible: Bool = false
    
    @State
    private var deleteItem: Bool = false
    
    @State
    private var isDeleted: Bool = false
    
    
    init(_ item: Garment) {
        self.item = item
        
        let itemId = item.id
        self._outfits = Query(
            filter: #Predicate<Outfit> { outfit in
                outfit.garments.contains {
                    $0.id == itemId
                }
            },
            sort: \Outfit.name,
            order: .forward
        )
    }
    
    
    
    var body: some View {
        
        HeroListView(
            item.imagePath,
            colorPlaceholder: Color(hex: item.color)
        ) {
            titleSection
            
        } content: { // MARK: - Sections
            sectionStyleAndCategory
            
            if !item.composition.isEmpty {
                sectionComposition
            }
            
            sectionCare
            
            if !outfits.isEmpty {
                outfitsLazyRow
            }
            
        }
        .sensoryFeedback(.success, trigger: isDeleted)
        .toolbar {
            ToolbarItem {
                Button(role: .destructive) {
                    deleteItem = true
                    
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
        .sheet(isPresented: self.$isModifySheetVisible) {
            NavigationStack {
                GarmentEditorView(garment: self.item)
            }
        }
        .alert(
            "Delete Garment?",
            isPresented: self.$deleteItem
        ) {
            
            Button("Delete", role: .destructive) {
                withAnimation {
                    self.garmentManager.delete(item)
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
            Text(self.item.name)
                .font(.system(size: 65))
                .fontWeight(.bold)
                .fontDesign(.default)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
            
            HStack {
                if let brand = self.item.brand {
                    Text("\(brand) -")
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                        .fontDesign(.default)
                }
                
                Text("\(self.item.purchaseDate.formatted(date: .abbreviated, time: .omitted))")
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                    .fontDesign(.default)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    private var sectionStyleAndCategory: some View {
        
        SectionList(titleKey: "Details") {
            RowInfoView(
                title: "Type",
                value: self.item.category.label
            )
            
            RowInfoView(title: "Model", value: self.item.subCategory.rawValue)
            
            RowInfoView(title: "Season", value: self.item.season.rawValue)
            
            if let price = item.price {
                RowInfoView(
                    title: "Price",
                    value: price.formatted(
                        .currency(
                            code: Locale.current.currency?.identifier ?? "EUR"
                        )
                    )
                )
            }
        }
    }
    
    
    
    @ViewBuilder
    private var sectionComposition: some View {
        SectionList(titleKey: "Composition") {
            
            ForEach(self.item.composition, id: \.id) { item in
                CompositionRowView(
                    fabricName: item.fabric.rawValue,
                    percentage: item.percentual,
                    color     : Color(hex: self.item.color)
                )
                .padding(.vertical, 10)
            }
        }
    }
    
    
    
    @ViewBuilder
    var sectionCare: some View {
        SectionList(titleKey: "Care & Usage") {
            rowWashSymbols
            
            // Stats
            RowInfoView(
                title: "Last Washed",
                value: self.item.lastWashingDate?.formatted(date: .abbreviated, time: .omitted) ?? "Never"
            )
            
            RowInfoView(
                title: "Wear Count",
                value: self.item.wearCount == 0 ? "Unworn" : "\(self.item.wearCount) times"
            )
        }
    }
    
    @ViewBuilder
    private var rowWashSymbols: some View {
        if !self.item.washingSymbols.isEmpty {
            ScrollView(
                .horizontal,
                showsIndicators: false
            ) {
                LazyHStack(spacing: 12) {
                    
                    ForEach(self.item.washingSymbols, id: \.id) { symbol in
                        VStack(alignment: .center) {
                            Image(symbol.iconName ?? "")
                                .frame(width: 30, height: 30)
                                .foregroundStyle(.secondary)
                            
                            Text(symbol.label)
                                .font(.caption2)
                                .fontWeight(.regular)
                                .fontDesign(.default)
                                .foregroundStyle(.secondary)
                        }
                        .frame(width: 60, height: 60)
                        .background(.clear)
                        .padding(5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(.tertiary, lineWidth: 1)
                        )
                    }
                }
                .padding(.vertical, 8)
            }
            .padding(.vertical, 5)
        }
    }
    
    @ViewBuilder
    private var outfitsLazyRow: some View {
        SectionList(titleKey: "Outfits") {
        
            ScrollView(.horizontal) {
                LazyHStack(spacing: 15) {
                    ForEach(self.outfits, id: \.id) { outfit in
                        
                        ModelCardView(
                            title    : outfit.name,
                            imagePath: outfit.fullLookImagePath
                        )
                        .frame(width: 150, height: 250)
                        
                    }
                }
            }
        }
        .padding(.vertical, 10)
    }
    

}

#Preview {
    
    let garment = Garment(
        name: "Maglia",
        brand: "Levi`s",
        color: "2570ba",
        composition: [],
        category: .top,
        subCategory: .blazers,
        season: .summer,
        style: .casual
    )
    
    InfoGarmentView(garment)
}
