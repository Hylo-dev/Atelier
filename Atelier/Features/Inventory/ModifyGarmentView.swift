//
//  ModifyGarmentView.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 17/02/26.
//

import SwiftUI
import PhotosUI

struct ModifyGarmentView: View {
    
    @Environment(\.dismiss)
    var dismiss
    
    @Environment(\.modelContext)
    private var modelContext
    
    @Binding
    private var garmentManager: GarmentManager?
    
    private var item: Garment
    
    
    // MARK: - Garment Attributes
    
    @State
    private var name: String
    
    @State
    private var brand: String
    
    @State
    private var color: Color
    
    @State
    private var selectedType: GarmentType
    
    @State
    private var washingSymbols: Set<WashingSymbol>
    
    @State
    private var purchaseDate: Date
    
    
    // MARK: - Image Handling States
    
    @State
    private var selectedItem: PhotosPickerItem?
    
    @State
    private var selectedImage: Image?
    
    @State
    private var uiImageToSave: UIImage?
    
    @State
    private var imagePath: String?
    
    @State
    private var showCamera = false
    
    @State
    private var showGalleryPicker = false
    
    @State
    private var showImageSourceDialog = false
    
    init(
        garmentManager: Binding<GarmentManager?>,
        garment       : Garment,
        
    ) {
        self.item            = garment
        self.name            = garment.name
        self.brand           = garment.brand ?? ""
        self.color           = Color(hex: garment.color)
        self.selectedType    = garment.type
        self.washingSymbols  = Set(garment.washingSymbols)
        self.purchaseDate    = garment.purchaseDate
        self.imagePath       = garment.imagePath
        
        if let path = garment.imagePath, let image = ImageStorage.loadImage(from: path) {
            self.selectedImage = Image(uiImage: image)
        }
        
        self._garmentManager = garmentManager
    }
    
    var body: some View {
        Form {
            Section {
                HStack {
                    
                    Spacer()
                    
                    Button {
                        self.showImageSourceDialog = true
                        
                    } label: {
                        self.avatarView
                    }
                    .buttonStyle(.plain)
                    
                    Spacer()
                    
                }
                .padding(.vertical, 10)
            }
            .listRowBackground(Color.clear)
            
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
                    items    : WashingSymbol.allCases
                ) { symbols in
                    Text(symbols.label).tag(symbols)
                }
            }
        }
        .navigationTitle("New garment")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", systemImage: "xmark") { dismiss() }
            }
            
            ToolbarItem(placement: .confirmationAction) {
                Button("Finish", systemImage: "checkmark") {
                    updateGarment()
                }
                .fontWeight(.bold)
                .disabled(self.name.isEmpty)
            }
        }
        .confirmationDialog("Choose Image", isPresented: $showImageSourceDialog) {
            Button("Camera") {
                showCamera = true
            }
            
            Button("Gallery") {
                showGalleryPicker = true
            }
            
            if selectedImage != nil {
                Button("Remove Photo", role: .destructive) {
                    self.selectedImage = nil
                    self.uiImageToSave = nil
                    self.imagePath = nil
                }
            }
            
        } message: {
            Text("Select how you want to add the photo")
        }
        .sheet(isPresented: $showCamera) {
            CameraView(onImageCaptured: { filename, image in
                self.selectedImage = Image(uiImage: image)
                self.uiImageToSave = image
                self.imagePath = filename
            })
            .ignoresSafeArea()
        }
        .photosPicker(isPresented: $showGalleryPicker, selection: $selectedItem, matching: .images)
        .onChange(of: selectedItem) {
            Task {
                if let data = try? await selectedItem?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    
                    self.uiImageToSave = uiImage
                    self.selectedImage = Image(uiImage: uiImage)
                    
                    if let filename = ImageStorage.saveImage(uiImage) {
                        self.imagePath = filename
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private var avatarView: some View {
        ZStack {
            if let displayImage = self.selectedImage {
                displayImage
                    .resizable()
                    .scaledToFill()
                    .frame(width: 140, height: 140)
                    .clipShape(Circle())
                
            } else {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 140, height: 140)
                    .overlay {
                        Image(systemName: "camera.fill")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                    }
            }
        }
    }
    
    func updateGarment() {
        
        self.item.name           = self.name
        self.item.brand          = self.brand.isEmpty ? nil : self.brand
        self.item.color          = self.color.toHex() ?? "nil"
        self.item.type           = self.selectedType
        self.item.washingSymbols = Array(self.washingSymbols)
        self.item.purchaseDate   = self.purchaseDate
        self.item.imagePath      = self.imagePath ?? ""
         
        
        if let manager = self.garmentManager {
            manager.updateGarment()
            
        } else { print("Manager is nil") }
        
        dismiss()
    }
}
