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
    
    @State
    private var isDeleted: Bool = false
    
    
    
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
        .sensoryFeedback(.success, trigger: isDeleted)
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
                do {
                    isDeleted.toggle()
                    try manager.delete(item)
                    
                } catch {
                    print(error.localizedDescription) // TODO: Manage errore
                }
                
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
                title: "Created",
                value: item.dateCreated.formatted(
                    date: .abbreviated,
                    time: .omitted
                )
            )
            
            RowInfoView(
                title: "Status",
                value: item.status.rawValue
            )
        }
    }
    
    
    
    @ViewBuilder
    private var settingsSection: some View {
        
        Section("Settings") {
            
            RowInfoView(
                title: "Temperature",
                value: "\(item.targetTemperature)°"
            )
            
            RowInfoView(
                title: "Program",
                value: item.suggestedProgram.displayName
            )
            
            RowInfoView(
                title: "Washing Time",
                value: formatWashingMachineTime(
                    item.suggestedProgram.washingTime
                )
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
                        .frame(width: 150, height: 250)
                    }
                }
            }
        }
    }
    
    
    @ViewBuilder
    private var symbolsSection: some View {
        
        Section("Care Instructions") {
            
            ForEach(Array(item.laundrySymbols), id: \.id) { symbol in
                IconRowView(
                    symbol.iconName ?? "questionmark",
                    title: symbol.title
                )
            }
            
        }
        
    }
    
    
    
    // MARK: - Handlers
    
    private func formatWashingMachineTime(
        _ totalMinutes: Int
    ) -> String {
        let hours   = totalMinutes / 60
        let minutes = totalMinutes % 60
        
        if hours >= 1 {
            return "\(hours)h \(minutes)m"
        }
        
        if minutes >= 10 {
            return "\(minutes)m"
        }
        
        return String(format: "%d:00", minutes)
    }
    
}
