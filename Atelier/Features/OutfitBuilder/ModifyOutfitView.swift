//
//  ModifyOutfitView.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 24/02/26.
//

import SwiftUI
import PhotosUI

struct ModifyOutfitView: View {
    
    @Environment(\.dismiss)
    var dismiss
    
    @Environment(\.modelContext)
    private var modelContext
    
    @Binding
    private var manager: OutfitManager?
    
    private var outfit: Outfit
    
    
    
    // MARK: - Outfit Attributes
    
    @State
    private var name: String
    
    @State
    private var lastWornDate: Date
    
    @State
    private var selectedSeason: Season
    
    @State
    private var selectedStyle: GarmentStyle
    
    @State
    private var selectedGarments: Set<Garment>
    
    @State
    private var wearCount: Int
    
    
    
    // MARK: - Image selection variables
    
    @State
    private var photoPickerItem: PhotosPickerItem?
    
    @State
    private var imagePath: String?
    
    @State
    private var selectedImage: Image?
    
    @State
    private var uiImageToSave: UIImage?
    
    
    
    // MARK: - Sheet variables
    
    @State
    private var isCameraSheetVisible: Bool
    
    @State
    private var isPhotoPickerVisible: Bool
    
    @State
    private var isAlertImageVisible: Bool
    
    
    
    // MARK: - Init
    
    init(
        manager: Binding<OutfitManager?>,
        outfit: Outfit
    ) {
        self._manager = manager
        self.outfit   = outfit
        
        self._name             = State(initialValue: outfit.name)
        self._lastWornDate     = State(
            initialValue: outfit.lastWornDate ?? .now
        )
        self._selectedSeason   = State(initialValue: outfit.season)
        self._selectedStyle    = State(initialValue: outfit.style)
        self._selectedGarments = State(initialValue: Set(outfit.garments))
        self._wearCount        = State(initialValue: outfit.wearCount)
        self._imagePath        = State(initialValue: outfit.fullLookImagePath)
        
        self.photoPickerItem  = nil
        self.selectedImage    = nil
        self.uiImageToSave    = nil
        
        self.isCameraSheetVisible = false
        self.isPhotoPickerVisible = false
        self.isAlertImageVisible  = false
    }
        
    var body: some View {
        
        Form {
            
            Section {
                HStack {
                    
                    Spacer()
                    
                    Button {
                        self.isAlertImageVisible = true
                        
                    } label: {
                        AvatarView(
                            self.imagePath,
                            color: .accentColor,
                            icon : "hanger"
                        )
                    }
                    .buttonStyle(.plain)
                    
                    Spacer()
                    
                }
                .padding(.vertical, 10)
            }
            .listRowBackground(Color.clear)
            
            // MARK: - Sections
            
            self.sectionGeneralInfo
            
            self.sectionCare
            
            self.sectionStyleAndCategory
        }
        .navigationTitle("Edit outfit")
        .navigationBarTitleDisplayMode(.inline)
        .scrollDismissesKeyboard(.interactively)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", systemImage: "xmark") { dismiss() }
            }
            
            ToolbarItem(placement: .confirmationAction) {
                Button("Finish", systemImage: "checkmark") {
                    self.updateOutfit()
                }
                .fontWeight(.bold)
                .disabled(self.name.isEmpty)
            }
        }
        .confirmationDialog(
            "Choose Image",
            isPresented: self.$isAlertImageVisible,
            actions: self.confirmationDialogHandler,
            message: { Text("Select how you want to add the photo") }
        )
        .sheet(
            isPresented: self.$isCameraSheetVisible,
            content    : self.sheetHandler
        )
        .photosPicker(
            isPresented: self.$isPhotoPickerVisible,
            selection  : self.$photoPickerItem,
            matching   : .images
        )
        .onChange(
            of: self.photoPickerItem,
            selectedItemChanged
        )
        
    }
    
    
    // MARK: - Views
    
    @ViewBuilder
    var sectionGeneralInfo: some View {
        Section("Info Garment") {
            TextField("Name", text: self.$name)
            
            DatePicker(
                "Last worn date",
                selection: self.$lastWornDate,
                displayedComponents: [.date]
            )
        }
    }
    
    
    
    @ViewBuilder
    var sectionCare: some View {
        Section("Care") {
            
            Stepper(
                "Wear Count: \(self.wearCount) pieces",
                value: self.$wearCount,
                in   : 0...Int.max,
                step : 1
            )
            
        }
    }
    
    
    
    @ViewBuilder
    var sectionStyleAndCategory: some View {
        Section("Style & Category") {
            
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
                GarmentSelectionView(
                    selectedGarments: self.$selectedGarments
                )
                .navigationTitle("Garments")
                
            } label: {
                HStack {
                    Text("Garments")
                    
                    Spacer()
                    
                    
                    let count = self.selectedGarments.count
                    Text(count == 0 ? "None" : "\(count) selected")
                        .foregroundStyle(.secondary)
                    
                }
            }
        }
    }
    
    
    
    // MARK: - Handlers
    
    @ViewBuilder
    private func confirmationDialogHandler() -> some View {
        Button("Camera") {
            self.isCameraSheetVisible = true
        }
        
        Button("Gallery") {
            self.isPhotoPickerVisible = true
        }
        
        if self.selectedImage != nil {
            Button("Remove Photo", role: .destructive) {
                self.selectedImage = nil
                self.uiImageToSave = nil
                self.imagePath     = nil
            }
        }
    }
    
    
    
    @ViewBuilder
    private func sheetHandler() -> some View {
        CameraView(
            onImageCaptured: { filename, image in
                self.selectedImage = Image(uiImage: image)
                self.uiImageToSave = image
                self.imagePath     = filename
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
            if let data = try? await photoPickerItem?.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                
                self.uiImageToSave = uiImage
                self.selectedImage = Image(uiImage: uiImage)
                
                if let filename = ImageStorage.saveImage(uiImage) {
                    self.imagePath = filename
                }
            }
        }
    }
    
    
    
    func updateOutfit() {
        self.outfit.name              = self.name
        self.outfit.season            = self.selectedSeason
        self.outfit.style             = self.selectedStyle
        self.outfit.lastWornDate      = self.lastWornDate
        self.outfit.fullLookImagePath = self.imagePath ?? ""
        self.outfit.wearCount         = self.wearCount
        
        
        if let manager = self.manager {
            manager.updateOutfit()
            
        } else { print("ERROR: Manager is not available") }
        
        dismiss()
    }
}
