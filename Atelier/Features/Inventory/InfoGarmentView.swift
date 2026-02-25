//
//  InfoGarmentView.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 16/02/26.
//

import SwiftUI

struct InfoGarmentView: View {
    
    
    
    // MARK: - Parameters Variables
        
    @Binding
    var garmentManager: GarmentManager?
    
    let item: Garment
    
    
    
    // MARK: - Private State Variables
    
    @Environment(\.dismiss)
    private var dismiss
    
    @State
    private var isModifySheetVisible: Bool = false
    
    @State
    private var deleteItem: Bool = false
    
    
    
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
                ModifyGarmentView(
                    garmentManager: self.$garmentManager,
                    garment       : self.item
                )
            }
        }
        .alert(
            "Delete Garment?",
            isPresented: self.$deleteItem
        ) {
            
            Button("Delete", role: .destructive) {
                withAnimation {
                    self.garmentManager?.deleteGarment(self.item)
                }
                
                dismiss()
            }
            
        } message: {
            Text("Are you sure? This action cannot be undone.")
        }
    }
    
    
    
    // MARK: - Views
    
    
    
    @ViewBuilder
    private var headerSection: some View {
        Section {
            VStack(spacing: 5) {
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
        
        AvatarView(
            self.item.imagePath ?? "",
            color: itemColor,
            icon: "hanger"
        )
        .overlay(alignment: .bottomTrailing) {
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
        
        
    }
    
    
    
    @ViewBuilder
    private var sectionStyleAndCategory: some View {
        Section("Details") {
            
            RowInfo(title: "Type", value: self.item.category.label)
            RowInfo(title: "Model", value: self.item.subCategory.rawValue)
            RowInfo(title: "Season", value: self.item.season.rawValue)
            RowInfo(title: "Style", value: self.item.style.rawValue)
            RowInfo(title: "State", value: self.item.state.rawValue)
            
        }
    }
    
    
    
    @ViewBuilder
    private var sectionComposition: some View {
        Section("Composition") {
            
            ForEach(self.item.composition, id: \.id) { item in
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
                        
                        ForEach(self.item.washingSymbols, id: \.id) { symbol in
                            VStack(alignment: .center) {
                                Image(symbol.iconName ?? "")
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
                .padding(.top, 5)
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
