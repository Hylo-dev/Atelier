//
//  InfoLaundrySessionView.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 12/03/26.
//

import SwiftUI

struct InfoCareView: View {
    
    @Environment(\.dismiss)
    private var dismiss
    
    @Environment(ApplianceManager.self)
    private var manager
    
    let item: LaundrySession
    
    
    
    // MARK: - State variables
    
    
    @State
    private var isSelectionVisible: Bool
    
    
    @State
    private var didTriggerDelete: Bool = false
    
    
    
    init(_ item: LaundrySession) {
        self.item               = item
        self.isSelectionVisible = false
    }
    
    
    
    var body: some View {
        
        Form {
            
            // MARK: - Sections
            
            summarySection
            
            settingsSection
            
            if !item.garments.isEmpty {
                garmentsGridSection
            }
            
            symbolsSection
        }
        .sensoryFeedback(.success, trigger: didTriggerDelete)
        .toolbar {
            
            ToolbarItemGroup {
                Button(role: .destructive) {
                    didTriggerDelete = true
                    
                } label: {
                    Label("Delete", systemImage: "trash")
                }
                
                Button {
                    // self.isModifySheetVisible = true
                    
                } label: {
                    Label("Edit", systemImage: "pencil")
                }
            }
            
            ToolbarSpacer()
            
            if item.status == .planned {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isSelectionVisible = true
                        
                    } label: {
                        Label("Wash", systemImage: "washer.fill")
                    }
                }
            }
        }
        .sheet(isPresented: $isSelectionVisible) {
            
            NavigationStack {
                WashGarmentView(
                    garments: item.garments
                )
            }
            
        }
        .alert("Delete Session", isPresented: $didTriggerDelete) {
            Button("Delete", role: .destructive) {
                manager.delete(item)
                dismiss()
            }
            
        } message: {
            Text("This session and its data will be permanently removed.")
        }
    }
    
    
    
    // MARK: - Views
    
    @ViewBuilder
    private var summarySection: some View {
        
        Section("Summary") {
            
            RowInfoView(
                title: "Date Creation",
                value: item.dateCreated.formatted(
                    date: .abbreviated,
                    time: .omitted
                )
            )
            
            RowInfoView(title: "State", value: item.status.rawValue)
        }
    }
    
    
    
    @ViewBuilder
    private var settingsSection: some View {
        
        Section("Settings") {
            
            RowInfoView(
                title: "Temperature",
                value: "\(item.targetTemperature)"
            )
            
            RowInfoView(
                title: "Suggested Program",
                value: item.suggestedProgram.displayName
            )
            
            RowInfoView(
                title: "Bin Type",
                value: item.bin.displayName
            )
        }
    }
    
    
    
    @ViewBuilder
    private var garmentsGridSection: some View {
        
        Section("Garments") {
            
            let useTwoRows = item.garments.count > 3
            let rows = Array(
                repeating: GridItem(.fixed(125), spacing: 15),
                count    : useTwoRows ? 2 : 1
            )
            
            ScrollView(
                .horizontal,
                showsIndicators: false
            ) {
                
                LazyHGrid(
                    rows     : rows,
                    alignment: .center,
                    spacing  : 15
                ) {
                    
                    ForEach(item.garments, id: \.id) { garment in
                        ModelCardView(
                            title    : garment.name,
                            imagePath: garment.imagePath
                        )
                        .equatable()
                        .frame(width: 150, height: 250)
                    }
                    
                }
                
            }
        }
        
    }
    
    
    
    @ViewBuilder
    private var symbolsSection: some View {
        
        Section("Warnings") {
            
            ForEach(Array(item.laundrySymbols), id: \.id) { symbol in
                IconRowView(
                    symbol.iconName ?? "",
                    title: symbol.title
                )
            }
            
        }
        
    }
    
    
    
    // MARK: - Handlers
    
    
    
}
