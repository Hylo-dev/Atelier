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

    
    
    // MARK: - Outfit Attributes
    
    @State
    private var editorViewModel: OutfitEditorViewModel
    
    
    
    // MARK: - Manage image selection
    
    @State
    private var uiImageToSave: UIImage?
    
    @State
    private var isSaved: Bool = false
    
    @State
    private var showCamera: Bool = false
    
    
    
    init(_ item: Outfit? = nil) {
        self.outfit = item
        
        self._editorViewModel = State(
            initialValue: OutfitEditorViewModel(item)
        )
    }
    
    var body: some View {
                
        HeroListView(
            editorViewModel.fullLookImagePath,
            previewImage  : uiImageToSave,
            isImageClicked: $showCamera
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
                    editorViewModel.handleFinishAction(
                        image  : uiImageToSave,
                        manager: outfitManager
                    ) {
                        isSaved.toggle()
                        
                        Task {
                            try await Task.sleep(for: .seconds(0.2))
                            dismiss()
                        }
                    }
                }
                .fontWeight(.bold)
                .disabled(!editorViewModel.isFormValid)
            }
        }
        .fullScreenCover(
            isPresented: self.$showCamera,
            content    : sheetPhotoHandler
        )
        .alert("Ops! Something went wrong", isPresented: $editorViewModel.isAlertErrorVisible) {
            Button("Ok", role: .cancel) { }
            
        } message: {
            Text(editorViewModel.alertErrorMessage)
        }
        
    }
    
    
    
    // MARK: - Views
    
    @ViewBuilder
    private var sectionInfo: some View {
        SectionList(titleKey: "Info") {
            TextField("Name", text: $editorViewModel.name)
            
            if outfit != nil {
                DatePicker(
                    "Last worn date",
                    selection: $editorViewModel.lastWornDate,
                    displayedComponents: [.date]
                )
            }            
        }
    }
    
    @ViewBuilder
    var sectionCare: some View {
        SectionList(titleKey: "Care") {
            
            Stepper(
                value: $editorViewModel.wearCount,
                in   : 0...Int.max,
                step : 1
            ) {
                HStack(spacing: 4) {
                    Text("Times worn:")
                        
                    
                    Text("\(editorViewModel.wearCount)")
                        .fontWeight(.semibold)
                        .monospacedDigit()
                }
            }
        }
    }
    
    @ViewBuilder
    private var sectionStyleAndCategory: some View {
        SectionList(titleKey: "Style & Category") {
            
            PickerList("Season", selection: $editorViewModel.selectedSeason) {
                ForEach(Season.allCases, id: \.id) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            
            
            PickerList("Style", selection: $editorViewModel.selectedStyle) {
                ForEach(GarmentStyle.allCases, id: \.id) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            
            
            NavigationLink {
                GarmentSelectionView(selectedGarments: $editorViewModel.garments)
                    .navigationTitle("Garments")
                
            } label: {
                HStack {
                    Text("Garments")
                        .foregroundStyle(.primary)
                    
                    
                    Spacer()
                    
                    
                    HStack {
                        Text(editorViewModel.garments.isEmpty ? "None" : "\(editorViewModel.garments.count) selected")
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
    
    

    // MARK: - Views Handlers
    
    @ViewBuilder
    private func sheetPhotoHandler() -> some View {
        
        NavigationStack {
            CameraContainerView() { filename, image in
                self.uiImageToSave = image
                editorViewModel.fullLookImagePath = (filename as NSString).lastPathComponent
            }
        }
    }
}
