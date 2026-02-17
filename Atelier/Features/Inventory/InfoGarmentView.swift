//
//  InfoGarmentView.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 16/02/26.
//

import SwiftUI

struct InfoGarmentView: View {
    
    @Binding
    var garmentManager: GarmentManager?
    
    @State
    var isModifySheetVisible: Bool = false
    
    var item: Garment
    
    var body: some View {
        
        Form {
            
            // MARK: - Sections
            
            self.headerSection
                        
            self.sectionStyleAndCategory
            
            if !self.item.composition.isEmpty {
                self.sectionComposition
            }
            
            self.sectionCare
                        
        }
        .toolbar {
            ToolbarItem {
                Button("Modify") {
                    self.isModifySheetVisible = true
                }
            }
        }
        .sheet(
            isPresented: self.$isModifySheetVisible,
            onDismiss: { self.isModifySheetVisible = false }
        ) {
            NavigationStack {
                ModifyGarmentView(
                    garmentManager: self.$garmentManager,
                    garment       : self.item
                )
            }
        }
    }
    
    // MARK: - Views
    
    @ViewBuilder
    private var headerSection: some View {
        Section {
            VStack(spacing: 16) {
                self.headerImageView
                
                VStack(spacing: 3) {
                    Text(self.item.name)
                        .font(.title)
                        .fontWeight(.bold)
                        .fontDesign(.rounded)
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.center)
                    
                    if let brand = self.item.brand {
                        Text(brand)
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                            .fontDesign(.rounded)
                    }
                    
                    Text("Purchased on \(self.item.purchaseDate.formatted(date: .abbreviated, time: .omitted))")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .padding(.top, 4)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, 10)
        }
        .listRowInsets(EdgeInsets())
        .listRowBackground(Color.clear)
    }
    
    @ViewBuilder
    private var headerImageView: some View {
        let itemColor = Color(hex: self.item.color)
        
        ZStack(alignment: .bottomTrailing) {
            if let path = self.item.imagePath, let image = ImageStorage.loadImage(from: path) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .aspectRatio(3/4, contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
                
            } else {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(itemColor.gradient)
                    .aspectRatio(3/4, contentMode: .fit)
                    .overlay(
                        Image(systemName: "hanger")
                            .font(.system(size: 80))
                            .foregroundStyle(.white.opacity(0.5))
                    )
            }
            
            Button(action: {
                
            }) {
                Image(systemName: "view.3d")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(12)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(.white.opacity(0.3), lineWidth: 1)
                    )
            }
            .padding(16)
        }
        .padding(.horizontal, 16)
        .padding(.top, 10)
    }
    
    @ViewBuilder
    var sectionStyleAndCategory: some View {
        Section("Details") {
            
            RowInfo(title: "Type", value: self.item.category.label)
            RowInfo(title: "Model", value: self.item.subCategory.rawValue)
            RowInfo(title: "Season", value: self.item.season.rawValue)
            RowInfo(title: "Style", value: self.item.style.rawValue)
            
        }
    }
    
    @ViewBuilder
    var sectionComposition: some View {
        Section("Composition") {
            
            ForEach(self.item.composition) { item in
                CompositionRow(
                    fabricName: item.fabric.rawValue,
                    percentage: item.percentual,
                    color     : Color(hex: self.item.color)
                )
            }
        }
    }
    
    @ViewBuilder
    var sectionCare: some View {
        Section("Care & Usage") {
            if !self.item.washingSymbols.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    
                    HStack(spacing: 12) {
                        
                        ForEach(self.item.washingSymbols, id: \.self) { symbol in
                            VStack(alignment: .center) {
                                Image("do_not_machine_wash")
                                    .frame(width: 30, height: 30)
                                    .foregroundStyle(.secondary)
                                
                                Text(symbol.label)
                                    .font(.caption2)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(width: 60, height: 60)
                            .background(Color(uiColor: .secondarySystemGroupedBackground))
                            .cornerRadius(12)
                            .padding(5)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.primary.opacity(0.1), lineWidth: 1)
                            )
                        }
                    }
                    .padding(.vertical, 8)
                }
                .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 0))
            }
            
            // Stats
            RowInfo(
                title: "Last Washed",
                value: self.item.lastWashingDate?.formatted(date: .abbreviated, time: .omitted) ?? "Never"
            )
            
            RowInfo(
                title: "Wear Count",
                value: "\(self.item.wearCount) times"
            )
        }
    }

}

struct RowInfo: View {
    
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .fontWeight(.medium)
                .fontDesign(.rounded)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            Text(value)
                .fontWeight(.medium)
                .fontDesign(.rounded)
                .foregroundStyle(.primary)
        }
    }
}

struct CompositionRow: View {
    
    let fabricName: String
    let percentage: Double
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(self.fabricName)
                    .fontWeight(.medium)
                    .fontDesign(.rounded)
                
                Spacer()
                
                Text("\(Int(self.percentage))%")
                    .fontWeight(.bold)
                    .fontDesign(.rounded)
                    .foregroundStyle(.secondary)
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 6)
                    
                    Capsule()
                        .fill(self.color)
                        .frame(width: geo.size.width * (self.percentage / 100), height: 6)
                }
            }
            .frame(height: 6)
        }
        .padding(.vertical, 4)
    }
}
