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
            Section {
                HStack {
                    Spacer()
                    
                    VStack(spacing: 16) {
                        self.headerView
                        
                        Text(self.item.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .fontDesign(.rounded)
                            .multilineTextAlignment(.center)
                    }
                    
                    Spacer()
                }
                .padding(.vertical, 20)
            }
            .listRowBackground(Color.clear)
            
            Section("Garment Info") {
                if let brand = self.item.brand {
                    RowInfo(title: "Brand", value: brand)
                }
                
                RowInfo(title: "Type", value: self.item.type.rawValue)
                
                RowInfo(title: "Purchased on", value: self.item.purchaseDate.formatted(date: .long, time: .omitted))
                
                if self.item.wearCount > 0 {
                    HStack {
                        RowInfo(title: "Wear Count", value: "\(self.item.wearCount)")
                        
                        Spacer()
                        
                        Text("\(self.item.wearCount) times")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(.ultraThinMaterial, in: Capsule())
                    }
                }
            }
            
            Section("Care & Maintenance") {
                
                if let lastWash = self.item.lastWashingDate {
                    RowInfo(title: "Last Washed", value: lastWash.formatted(date: .long, time: .omitted))
                    
                } else {
                    RowInfo(title: "Last Washed", value: "Never")
                }
                
                if !self.item.washingSymbols.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Care Instructions")
                            .font(.caption)
                            .fontWeight(.medium)
                            .fontDesign(.rounded)
                            .foregroundStyle(.secondary)
                        
                        ScrollView(.vertical, showsIndicators: false) {
                            
                            VStack(
                                alignment: .leading,
                                spacing  : 5
                            ) {
                                ForEach(self.item.washingSymbols, id: \.self) { symbol in
                                    Text(symbol.label)
                                        .font(.default)
                                        .fontWeight(.semibold)
                                        .fontDesign(.rounded)
                                    
                                    if let last = self.item.washingSymbols.last, symbol != last {
                                        Divider()
                                    }
                                }
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .toolbar {
            
            ToolbarItem {
                Button("3D Model", systemImage: "view.3d") {
                    
                }
            }
            
            ToolbarSpacer(.fixed)
            
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
    
    @ViewBuilder
    private var headerView: some View {
        let itemColor = Color(hex: self.item.color)
        
        ZStack {
            if let path = self.item.imagePath, let image = ImageStorage.loadImage(from: path) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 160, height: 160)
                    .clipShape(Circle())
                    .shadow(color: itemColor.opacity(0.2), radius: 15, x: 0, y: 5)
                    .overlay(
                        Circle()
                            .stroke(itemColor, lineWidth: 6)
                    )
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.2), lineWidth: 6)
                    )
                
            } else {
                Circle()
                    .fill(itemColor)
                    .frame(width: 160, height: 160)
                    .shadow(color: itemColor.opacity(0.3), radius: 15)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                    .overlay(
                        Image(systemName: "hanger")
                            .font(.system(size: 60))
                            .foregroundStyle(.secondary)
                    )
            }
        }
    }
}

struct RowInfo: View {
    
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .fontDesign(.rounded)
                .foregroundStyle(.secondary)
            
            Text(value)
                .font(.body)
                .fontWeight(.regular)
                .fontDesign(.rounded)
                .foregroundStyle(.primary)
        }
        .padding(.vertical, 2)
    }
}
