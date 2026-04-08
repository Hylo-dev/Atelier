//
//  InfoGarmentView.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 16/02/26.
//

import SwiftUI
import SwiftData

struct InfoGarmentView: View {
    
    @Environment(\.dismiss)
    private var dismiss
    
    
    // MARK: - Parameters Variables
    
    private let item: Garment
    
    private let color: [Color]
    
    private var garmentManager: any Manager<Garment>
    
    
    @State
    private var isModifySheetVisible: Bool = false
    
    @State
    private var alertManager = AlertManager()
    
    @State
    private var isDeleted: Bool = false
    
    
    private let formattedDate : String
    private let formattedPrice: String?
    

    init(
        _ item        : Garment,
        garmentManager: any Manager<Garment>
    ) {
        self.item           = item
        self.color          = [Color(hex: item.color)]
        self.garmentManager = garmentManager
        
        self.formattedDate = item.purchaseDate.formatted(
            date: .abbreviated,
            time: .omitted
        )
        
        if let price = item.price {
            self.formattedPrice = price.formatted(
                .currency(
                    code: Locale.current.currency?.identifier ?? "EUR"
                )
            )
        } else { self.formattedPrice = nil }
    }
    
    
    var body: some View {
        HeroListView(
            item.imagePath,
            colorPlaceholder: color
        ) {
            titleSection
            
        } content: {
            sectionStyleAndCategory
            
            if !item.composition.isEmpty {
                sectionComposition
            }
            
            sectionCare
            
            if !item.outfits.isEmpty {
                outfitsRow
            }
            
        }
        .sensoryFeedback(.success, trigger: isDeleted)
        .toolbar {
            ToolbarItem {
                Button(role: .destructive) {
                    alertManager.isPresent = true
                    alertManager.title     = "Delete Garment"
                    alertManager.message   = "Are you sure? This action cannot be undone."
                    
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
                        
            ToolbarItem {
                Button {
                    isModifySheetVisible = true
                    
                } label: {
                    Label("Edit", systemImage: "pencil")
                }
            }
        }
        .sheet(isPresented: $isModifySheetVisible) {
            NavigationStack {
                GarmentEditorView(garment: item)
            }
        }
        .alert(
            alertManager.title,
            isPresented: $alertManager.isPresent
        ) {
            
            Button("Delete", role: .destructive) {
                withAnimation {
                    do {
                        try garmentManager.delete(item)
                        
                    } catch {
                        print(error.localizedDescription) // TODO: Manage error
                    }
                    
                    isDeleted.toggle()
                }
                
                dismiss()
            }
            
        } message: {
            Text(alertManager.message)
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
                
                Text(formattedDate)
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
            
            if let price = formattedPrice {
                RowInfoView(
                    title: "Price",
                    value: price
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
    private var outfitsRow: some View {
        
        HorizontalScrollList(
            title: "Outfits",
            items: item.outfits
        ) { outfit in
            ModelCardView(
                title    : outfit.name,
                imagePath: outfit.fullLookImagePath
            )
            .frame(width: 150, height: 250)
        }
    }
}

#Preview {
    @Previewable
    @Environment(GarmentManager.self)
    var garmentManager
    
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
    
    InfoGarmentView(
        garment,
        garmentManager: garmentManager
    )
}
