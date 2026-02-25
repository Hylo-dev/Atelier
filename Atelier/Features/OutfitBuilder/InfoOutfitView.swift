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
    
    
    
    var body: some View {
        
        Form {
            
            // MARK: - Sections
            
            self.headerSection
                        
            self.sectionStyleAndCategory
            
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
                ModifyOutfitView(
                    manager: self.$manager,
                    outfit : self.outfit
                )
            }
        }
        .alert(
            "Delete Garment?",
            isPresented: self.$deleteItem
        ) {
            
            Button("Delete", role: .destructive) {
                withAnimation {
                    self.manager?.deleteOutfit(self.outfit)
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
                    Text(self.outfit.name)
                        .font(.title)
                        .fontWeight(.bold)
                        .fontDesign(.rounded)
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.center)
                    
                    if let date = self.outfit.lastWornDate {
                        Text("Last worn date \(date.formatted(date: .abbreviated, time: .omitted))")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                            .padding(.top, 4)
                    }
                    
                    
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
        AvatarView(
            self.outfit.fullLookImagePath,
            color: .accentColor,
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
            
            RowInfo(title: "Season", value: self.outfit.season.rawValue)
            RowInfo(title: "Style", value: self.outfit.style.rawValue)
            
        }
    }
    
    
    
    @ViewBuilder
    var sectionCare: some View {
        Section("Care & Usage") {
            
            RowInfo(
                title: "Ready to Wear",
                value: self.outfit.stateWear
            )
            
            
            if self.outfit.missingItemsCount > 0 {
                RowInfo(
                    title: "Missing garments",
                    value: "\(self.outfit.missingItemsCount) pieces"
                )
            }
            
            
            if self.outfit.wearCount > 0 {
                RowInfo(
                    title: "Wear Count",
                    value: "\(self.outfit.wearCount) times"
                )
            }
            
            
        }
    }

}
