//
//  AddOutfit.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 17/02/26.
//

import SwiftUI
import PhotosUI
import UIKit

struct AddOutfitView: View {
    
    @Environment(\.dismiss)
    private var dismiss
    
    @Environment(\.modelContext)
    private var modelContext
    
    @Binding
    var outfitManager: OutfitManager?
    
    // MARK: - Outfit Attributes
    
    @State
    private var name: String = ""
    
    @State
    private var garments: Set<Garment> = []
    
    @State
    private var fullLookImagePath: String?
    
    @State
    private var selectedSeason: Season = .summer
    
    @State
    private var selectedStyle: GarmentStyle = .casual
    
    // MARK: - Manage image selection
    
    @State
    private var selectedItem: PhotosPickerItem?
    
    @State
    private var selectedImage: Image?
    
    @State
    private var uiImageToSave: UIImage?
    
    @State
    private var showCamera = false
    
    @State
    private var showGalleryPicker = false
    
    @State
    private var showImageSourceDialog = false
    
    var body: some View {
        
        Form {
            Section {
                HStack {
                    Spacer()
                    
                    Button {
                        self.showImageSourceDialog = true
                        
                    } label: {
                        AvatarView(
                            self.fullLookImagePath,
                            color  : .accentColor,
                            icon   : "tshirt",
                            uiImage: self.uiImageToSave
                        )
                    }
                    .buttonStyle(.plain)
                    
                    Spacer()
                    
                }
                .padding(.vertical, 10)
            }
            .listRowBackground(Color.clear)
            
            // MARK: - Sections
            
            // Section 1: Style & Category
            self.sectionStyleAndCategory
            
        }
        .navigationTitle("New outfit")
        .navigationBarTitleDisplayMode(.inline)
        .scrollDismissesKeyboard(.interactively)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", systemImage: "xmark") { dismiss() }
            }
            
            ToolbarItem(placement: .confirmationAction) {
                Button("Finish", systemImage: "checkmark") {
                    saveOutfit()
                }
                .fontWeight(.bold)
                .disabled(self.name.isEmpty || self.garments.count < 2)
            }
        }
        .confirmationDialog(
            "Choose Image",
            isPresented: self.$showImageSourceDialog,
            actions: confirmationDialogHandler,
            message: { Text("Select how you want to add the photo") }
        )
        .sheet(
            isPresented: self.$showCamera,
            content    : sheetPhotoHandler
        )
        .photosPicker(
            isPresented: $showGalleryPicker,
            selection  : $selectedItem,
            matching   : .images
        )
        .onChange(of: self.selectedItem) { _, newValue in
            Task {
                
                if let data = try await newValue?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    
                    await MainActor.run {
                        self.uiImageToSave = uiImage
                        self.selectedImage = Image(uiImage: uiImage)
                    }
                }                
            }
        }
    }
    
    
    
    // MARK: - Views
    
    
    
    @ViewBuilder
    var sectionStyleAndCategory: some View {
        Section("Style & Category") {
            TextField("Name", text: self.$name)
            
            Picker("Season", selection: self.$selectedSeason) {
                ForEach(Season.allCases, id: \.id) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            
            Picker("Style", selection: self.$selectedStyle) {
                ForEach(GarmentStyle.allCases, id: \.id) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            
            NavigationLink {
                GarmentSelectionView(selectedGarments: self.$garments)
                    .navigationTitle("Garments")
                
            } label: {
                HStack {
                    Text("Garments")
                    
                    Spacer()
                    
                    Text(self.garments.isEmpty ? "None" : "\(self.garments.count) selected")
                        .foregroundStyle(.secondary)
                    
                }
            }
        }
    }
    
    

    // MARK: - Handlers
    
    
    
    @ViewBuilder
    private func confirmationDialogHandler() -> some View {
        Button("Camera") {
            self.showCamera = true
        }
        
        Button("Gallery") {
            self.showGalleryPicker = true
        }
        
        if self.selectedImage != nil {
            Button("Remove Photo", role: .destructive) {
                self.selectedImage     = nil
                self.uiImageToSave     = nil
                self.fullLookImagePath = nil
            }
        }
    }
    
    
    
    @ViewBuilder
    private func sheetPhotoHandler() -> some View {
        CameraView(
            onImageCaptured: { filename, image in
                self.selectedImage = Image(uiImage: image)
                self.uiImageToSave = image
                self.fullLookImagePath = (filename as NSString).lastPathComponent
            },
            mode: .photo
        )
        .ignoresSafeArea()
    }
    
    
    
    private func saveOutfit() {
        
        if let imageToSave = self.uiImageToSave,
           let filename = ImageStorage.saveImage(imageToSave) {
            self.fullLookImagePath = (filename as NSString).lastPathComponent
        }
                
        let newOutfit = Outfit(
            name             : self.name,
            garments         : Array(self.garments),
            season           : self.selectedSeason,
            fullLookImagePath: self.fullLookImagePath,
            style            : self.selectedStyle
        )
        
        if let manager = self.outfitManager {
            manager.createOutfit(newOutfit)
            
        } else { print("Outfit manager is nil") }
        
        dismiss()
    }
}
