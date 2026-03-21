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
    
    @Environment(OutfitManager.self)
    private var outfitManager: OutfitManager
    
    
    
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
    private var uiImageToSave: UIImage?
    
    @State
    private var showCamera: Bool
    
    @State
    private var showGalleryPicker: Bool
    
    @State
    private var showImageSourceDialog: Bool
    
    
    
    // MARK: - Alert Management
    
    @State
    private var alertErrorMessage: String = ""
    
    @State
    private var isAlertErrorVisible: Bool = false
    
    
    
    // MARK: - Validation
    private var isFormValid: Bool {
        let isNameValid       = !name.trimmingCharacters(in: .whitespaces).isEmpty
        let hasEnoughGarments = garments.count >= 2
        
        return isNameValid && hasEnoughGarments
    }

    
    
    init(_ outfit: Outfit? = nil) {
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
            previewImage  : uiImageToSave,
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
                    handleFinishAction()
                }
                .fontWeight(.bold)
                .disabled(!isFormValid)
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
        .alert("Ops! Something went wrong", isPresented: $isAlertErrorVisible) {
            Button("Ok", role: .cancel) { }
            
        } message: {
            Text(alertErrorMessage)
        }
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
    
    

    // MARK: - Views
        
    @ViewBuilder
    private func confirmationDialogHandler() -> some View {
        Button("Camera") {
            self.showCamera = true
        }
        
        Button("Gallery") {
            self.showGalleryPicker = true
        }
        
        if self.uiImageToSave != nil || self.fullLookImagePath != nil {
            Button("Remove Photo", role: .destructive) {
                self.uiImageToSave     = nil
                self.fullLookImagePath = nil
            }
        }
    }
    
    
    
    @ViewBuilder
    private func sheetPhotoHandler() -> some View {
        
        CameraContainerView() { filename, image in
            self.uiImageToSave = image
            self.fullLookImagePath = (filename as NSString).lastPathComponent
        }
        .ignoresSafeArea()
    }
    
    
    
    private func selectedItemChanged(
        _ oldValue: PhotosPickerItem?,
        _ newValue: PhotosPickerItem?
    ) {
        Task {
            if let data = try? await selectedItem?.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                
                await MainActor.run {
                    self.uiImageToSave = uiImage
                }
            }
        }
    }
    
    
    
    // MARK: - Handlers
    
    private func handleFinishAction() {
        let success = if outfit == nil {
            saveOutfit()
            
        } else { updateOutfit() }
        
        if success {
            isSaved.toggle()
            
            Task {
                try await Task.sleep(for: .seconds(0.2))
                dismiss()
            }
        }
    }
    
    
    private func saveOutfit() -> Bool {
        
        if let imageToSave = self.uiImageToSave {
            let result = ImageStorage.saveImage(imageToSave)
            
            switch result {
                case .success(let filename):
                    fullLookImagePath = (filename as NSString).lastPathComponent
                    
                case .failure(let error):
                    alertErrorMessage   = error.localizedDescription
                    isAlertErrorVisible = true
                    return false
            }
        }
                        
        let newOutfit = Outfit(
            name             : self.name,
            garments         : Array(self.garments),
            season           : self.selectedSeason,
            fullLookImagePath: self.fullLookImagePath,
            style            : self.selectedStyle
        )
        
        outfitManager.insert(newOutfit)
        return true
    }
    
    private func updateOutfit() -> Bool {
        guard let outfit = outfit else { return false }
        
        if let imageToSave = self.uiImageToSave {
            
            if let oldPath = self.outfit?.fullLookImagePath {
                ImageStorage.deleteImage(filename: oldPath)
            }
            
            switch ImageStorage.saveImage(imageToSave) {
                case .success(let filename):
                    fullLookImagePath = (filename as NSString).lastPathComponent
                    
                case .failure(let error):
                    alertErrorMessage   = error.localizedDescription
                    isAlertErrorVisible = true
                    return false
            }
        }
        
        outfit.name              = self.name
        outfit.season            = self.selectedSeason
        outfit.style             = self.selectedStyle
        outfit.lastWornDate      = self.lastWornDate
        outfit.fullLookImagePath = self.fullLookImagePath
        outfit.wearCount         = self.wearCount
        outfit.garments          = Array(self.garments)
        
        
        outfitManager.update()
        return true
    }
}
