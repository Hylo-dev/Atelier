//
//  AddOutfit.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 17/02/26.
//

import SwiftUI
import PhotosUI

struct OutfitEditorView: View {
    
    @Environment(\.dismiss)
    private var dismiss
    
    @Environment(\.modelContext)
    private var modelContext
    
    @Binding
    var outfitManager: OutfitManager?
    
    let outfit: Outfit?
    
    @State
    private var isSaved: Bool
    
    
    // MARK: - Outfit Attributes
    
    @State
    private var name: String
    
    @State
    private var garments: Set<Garment>
    
    @State
    private var fullLookImagePath: String?
    
    @State
    private var selectedSeason: Season
    
    @State
    private var selectedStyle: GarmentStyle
    
    @State
    private var lastWornDate: Date
    
    @State
    private var wearCount: Int
    
    
    
    // MARK: - Manage image selection
    
    @State
    private var selectedItem: PhotosPickerItem?
    
    @State
    private var selectedImage: Image?
    
    @State
    private var uiImageToSave: UIImage?
    
    @State
    private var showCamera: Bool
    
    @State
    private var showGalleryPicker: Bool
    
    @State
    private var showImageSourceDialog: Bool
    
    init(
        outfitManager: Binding<OutfitManager?>,
        outfit       : Outfit? = nil
    ) {
        self._outfitManager    = outfitManager
        self.outfit            = outfit
        
        _isSaved               = State(initialValue: false)
        _name                  = State(initialValue: outfit?.name ?? "")
        _garments              = State(initialValue: Set(outfit?.garments ?? []))
        _fullLookImagePath     = State(initialValue: outfit?.fullLookImagePath)
        _selectedSeason        = State(initialValue: outfit?.season ?? .summer)
        _selectedStyle         = State(initialValue: outfit?.style ?? .casual)
        _showCamera            = State(initialValue: false)
        _showGalleryPicker     = State(initialValue: false)
        _showImageSourceDialog = State(initialValue: false)
        _lastWornDate          = State(initialValue: outfit?.lastWornDate ?? .now)
        _wearCount             = State(initialValue: outfit?.wearCount ?? 0)
                
    }
    
    var body: some View {
                
        HeroListView(
            fullLookImagePath,
            isImageClicked: $showImageSourceDialog
        ) {
            
        } content: { // MARK: - Section
            sectionInfo
            
            if outfit != nil { sectionCare }
            
            // Section 1: Style & Category
            self.sectionStyleAndCategory
        }
        .sensoryFeedback(.success, trigger: self.isSaved)
        .navigationTitle(outfit == nil ? "New Outfit" : "Edit Outfit")
        .navigationBarTitleDisplayMode(.inline)
        .scrollDismissesKeyboard(.interactively)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", systemImage: "xmark") { dismiss() }
            }
            
            ToolbarItem(placement: .confirmationAction) {
                Button("Finish", systemImage: "checkmark") {
                    if outfit == nil {
                        saveOutfit()
                        
                    } else { updateOutfit() }
                    
                    isSaved.toggle()
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
        .onChange(
            of: self.selectedItem,
            selectedItemChanged
        )
    }
    
    
    
    // MARK: - Views
    
    @ViewBuilder
    private var sectionInfo: some View {
        SectionList(titleKey: "Info") {
            TextField("Name", text: self.$name)
            
            if outfit != nil {
                DatePicker(
                    "Last worn date",
                    selection: self.$lastWornDate,
                    displayedComponents: [.date]
                )
            }            
        }
    }
    
    @ViewBuilder
    var sectionCare: some View {
        SectionList(titleKey: "Care") {
            
            Stepper(
                value: self.$wearCount,
                in   : 0...Int.max,
                step : 1
            ) {
                HStack(spacing: 4) {
                    Text("Times worn:")
                        
                    
                    Text("\(self.wearCount)")
                        .fontWeight(.semibold)
                        .monospacedDigit()
                }
            }
        }
    }
    
    @ViewBuilder
    private var sectionStyleAndCategory: some View {
        SectionList(titleKey: "Style & Category") {
            
            PickerList("Season", selection: self.$selectedSeason) {
                ForEach(Season.allCases, id: \.id) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            
            
            PickerList("Style", selection: self.$selectedStyle) {
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
                        .foregroundStyle(.primary)
                    
                    
                    Spacer()
                    
                    
                    HStack {
                        Text(self.garments.isEmpty ? "None" : "\(self.garments.count) selected")
                            .foregroundStyle(.tertiary)
                        
                        Image(systemName: "chevron.forward")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.tertiary)
                    }
                }
            }
            .tint(.primary)
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
    
    
    
    private func selectedItemChanged(
        _ oldValue: PhotosPickerItem?,
        _ newValue: PhotosPickerItem?
    ) {
        Task {
            if let data = try? await selectedItem?.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                
                self.uiImageToSave = uiImage
                self.selectedImage = Image(uiImage: uiImage)
                
                if let filename = ImageStorage.saveImage(uiImage) {
                    self.fullLookImagePath = filename
                }
            }
        }
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
            manager.insert(newOutfit)
            
        } else { print("Outfit manager is nil") }
        
        dismiss()
    }
    
    private func updateOutfit() {
        self.outfit!.name              = self.name
        self.outfit!.season            = self.selectedSeason
        self.outfit!.style             = self.selectedStyle
        self.outfit!.lastWornDate      = self.lastWornDate
        self.outfit!.fullLookImagePath = self.fullLookImagePath
        self.outfit!.wearCount         = self.wearCount
        self.outfit!.garments          = Array(self.garments)
        
        
        if let manager = self.outfitManager {
            manager.update()
            
        } else { print("ERROR: Manager is not available") }
        
        dismiss()
    }
}
