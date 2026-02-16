//
//  AddGarmentView.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 16/02/26.
//

import SwiftUI
import PhotosUI

struct AddGarmentView: View {
    @Environment(\.dismiss)
    var dismiss
    
    @Environment(\.modelContext)
    private var modelContext
    
    @Binding
    var garmentManager: GarmentManager?
    
    // MARK: - Garment Attributes
    
    @State 
    private var name: String = ""
    
    @State
    private var brand: String = ""
    
    @State
    private var color: Color = Color.clear
    
    
    @State
    private var selectedType: GarmentType = .top
    
    @State
    private var washingSymbols: Set<WashingSymbol> = []
    
    @State
    private var purchaseDate: Date = .now
    
    @State
    private var selectedItem: PhotosPickerItem?
    
    @State
    private var selectedImage: Image?
    
    @State
    private var imagePath: String?
    
    var body: some View {
        
        Form {
            Section {
                HStack {
                    
                    Spacer()
                    
                    VStack(spacing: 12) {
                        // Avatar Circolare
                        ZStack {
                            if let selectedImage = self.selectedImage {
                                selectedImage
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 140, height: 140)
                                    .clipShape(Circle())
                                
                            } else {
                                Circle()
                                    .fill(.ultraThinMaterial)
                                    .frame(width: 140, height: 140)
                                
                                Image(systemName: "camera.fill")
                                    .font(.largeTitle)
                                    .foregroundStyle(.secondary)
                            }
                        }

                        PhotosPicker(selection: self.$selectedItem, matching: .images) {
                            Text(self.selectedImage == nil ? "Add image" : "Modify image")
                                .font(.default)
                                .fontWeight(.regular)
                                .fontDesign(.rounded)
                            
                        }
                    }
                    
                    Spacer()
                    
                }
                .padding(.vertical, 10)
            }
            .listRowBackground(Color.clear)
                                
            // MARK: - Campi Dati
            Section {
                TextField("Name", text: self.$name)
                TextField("Brand", text: self.$brand)
            }
                    
            Section {
                
                ColorPicker(
                    "Color",
                    selection: self.$color
                )
                
                Picker("Type", selection: $selectedType) {
                    ForEach(GarmentType.allCases) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                
                DatePicker(
                    "Purchase Date",
                    selection: self.$purchaseDate,
                    displayedComponents: [.date]
                )
                
                MultiPicker(
                    "Washing Symbols",
                    selection: self.$washingSymbols,
                    items: WashingSymbol.allCases
                ) { symbols in
                    Text(symbols.label).tag(symbols)
                }
            }
        }
        // MARK: - Toolbar Nativa
        .navigationTitle("New garment")
        .navigationBarTitleDisplayMode(.inline) // Fondamentale per lo stile "Modal"
        .toolbar {
            // Bottone Sinistra (Annulla)
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", systemImage: "xmark") {
                    dismiss()
                }
            }
                
            // Bottone Destra (Fine)
            ToolbarItem(placement: .confirmationAction) {
                Button("Finish", systemImage: "checkmark") {
                    saveGarment()
                }
                .fontWeight(.bold)
                .disabled(self.name.isEmpty) // Disabilita se non valido
            }
        }
        // Logica caricamento foto...
        .onChange(of: selectedItem) {
            Task {
                if let data = try? await selectedItem?.loadTransferable(type: Data.self),
                    let uiImage = UIImage(data: data) {
                    selectedImage = Image(uiImage: uiImage)
                }
            }
        }
    }
    
    var isFormValid: Bool {
        !self.name.isEmpty && self.color == Color.clear
    }
        
    func saveGarment() {
        let newGarment = Garment(
            name: name,
            brand: brand.isEmpty ? nil : brand,
            color: color.description,
            type: selectedType,
            purchaseDate: purchaseDate
        )
        
        if let manager = self.garmentManager {
            manager.addGarment(newGarment)
            
        } else { print("Manager is nil") }
        
        dismiss()
    }
}
