//
//  InventoryView.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 15/02/26.
//

import SwiftUI
import QuickLook
import SwiftData

struct InventoryView: View {
    
    @Bindable
    var manager: CaptureManager
    
    // MARK: - State Properties
    
    @Environment(\.modelContext)
    private var context
    
    @Query(
        sort : \Garment.lastWashingDate,
        order: .reverse
    )
    private var garments: [Garment]
    
//    @State
//    private var models: [URL] = []
    
    @State
    private var garmentManager: GarmentManager?
    
    @State
    private var selectedModelForPreview: Garment?
    
    @State
    private var searchText: String = ""
    
    @State
    private var isSheetVisible: Bool = false
    
    private let columns = [
        GridItem(.adaptive(minimum: 150), spacing: 20)
    ]
    
    var body: some View {
        ScrollView {
            if self.garments.isEmpty {
                self.emptyStateView
                
            } else { self.modelGridView }
        }
        .padding()
        .onAppear {
            if self.garmentManager == nil {
                self.garmentManager = GarmentManager(context: self.context)
            }
            // loadModels()
        }
//        .refreshable { loadModels() }
//        .quickLookPreview(self.$selectedModelForPreview)
        .searchable(text: self.$searchText, prompt: "Cerca modelli...")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Add", systemImage: "plus") { self.isSheetVisible = true }
            }
        }
        .sheet(
            isPresented: self.$isSheetVisible,
            onDismiss: { self.isSheetVisible = false }
        ) {
            NavigationStack {
                AddGarmentView(garmentManager: self.$garmentManager)
                // ScannerView(manager: self.manager)
            }
        }
    }
    
    // MARK: - Subviews
    
    private var modelGridView: some View {
        LazyVGrid(columns: self.columns, spacing: 20) {
            
            ForEach(self.filteredModels, id: \.self) { item in
                
                ModelCard(item: item)
                    .onTapGesture {
                        selectedModelForPreview = item
                    }
                    .contextMenu {
                        Button(role: .destructive) {
                            // deleteModel(url: url)
                            
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        
//                        ShareLink(item: url) {
//                            Label("Export", systemImage: "square.and.arrow.up")
//                        }
                    }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "cube.box")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            Text("Nessun modello trovato")
                .font(.headline)
            
            Text("I modelli generati dallo scanner appariranno qui.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 400)
    }
    
    // MARK: - Logic
    
    var filteredModels: [Garment] {
        return if self.searchText.isEmpty {
            self.garments
            
        } else {
            self.garments.filter {
                $0.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
//    func loadModels() {
//        let fileManager = FileManager.default
//
//        guard let docs = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
//        let modelDir = docs.appendingPathComponent("Atelier_Models")
//        
//        if !fileManager.fileExists(atPath: modelDir.path) {
//            try? fileManager.createDirectory(at: modelDir, withIntermediateDirectories: true)
//        }
//        
//        do {
//            let files = try fileManager.contentsOfDirectory(at: modelDir, includingPropertiesForKeys: [.creationDateKey])
//            
//            withAnimation {
//                self.garments = files
//                    .filter { $0.pathExtension.lowercased() == "usdz" }
//                    .sorted {
//                        let date1 = (try? $0.resourceValues(forKeys: [.creationDateKey]))?.creationDate ?? Date.distantPast
//                        let date2 = (try? $1.resourceValues(forKeys: [.creationDateKey]))?.creationDate ?? Date.distantPast
//                        return date1 > date2
//                    }
//            }
//            
//        } catch {
//            print("Errore caricamento modelli: \(error.localizedDescription)")
//        }
//    }
    
    func deleteModel(item: Garment) {
        do {
            // try FileManager.default.removeItem(at: url)
            
            withAnimation {
                // self.garments.removeAll { $0.name == item.name }
            }
            
        } catch {
            print("Errore eliminazione: \(error.localizedDescription)")
        }
    }
}

// MARK: - Componente Card
struct ModelCard: View {
    let item: Garment
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack {
                Rectangle()
                    .fill(Color.secondary.opacity(0.1))
                
                Image(systemName: "cube.transparent")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40)
                    .foregroundStyle(.blue)
            }
            .frame(height: 120)
            .clipped()
            
            VStack(alignment: .leading, spacing: 4) {
                Text(self.item.name)
                    .font(.headline)
                    .lineLimit(1)
                    .truncationMode(.middle)
                
                Text(self.item.brand ?? "No_Brand")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .padding(4)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(4)
                
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.regularMaterial)
        }
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.primary.opacity(0.1), lineWidth: 1)
        )
        #if os(macOS)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        #endif
    }
}
