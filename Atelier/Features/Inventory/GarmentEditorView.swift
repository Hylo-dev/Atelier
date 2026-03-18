//
//  AddGarmentView.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 16/02/26.
//

import SwiftUI
import PhotosUI
import UIKit
import SwiftData

struct GarmentEditorView: View {
    @Environment(\.dismiss)
    var dismiss
    
    @Environment(ApplianceManager.self)
    private var applianceManager
    
    @Environment(GarmentManager.self)
    var garmentManager: GarmentManager
    
    
    @Query(
        sort : \LaundrySession.dateCreated,
        order: .forward
    )
    private var laundrySessions: [LaundrySession]
        
    private var item: Garment?
    
    
    // MARK: - Garment Attributes
    
    @State
    private var name: String
    
    @State
    private var brand: String
    
    @State
    private var color: Color
    
    @State
    private var wearCount: Int
    
    
    @State
    private var selectedFabrics: Set<GarmentFabric>
    
    @State
    private var selectedComposition: [GarmentComposition]
    
    @State
    private var selectedCategory: GarmentCategory
    
    @State
    private var selectedSubCategory: GarmentSubCategory
    
    @State
    private var selectedSeason: Season
    
    @State
    private var selectedStyle: GarmentStyle
    
    @State
    private var selectedState: GarmentState?
    
    
    
    @State
    private var washingSymbols: Set<LaundrySymbol>
    
    @State
    private var purchaseDate: Date
    
    
    
    // MARK: - Image Handling States
    
    @State
    private var selectedItem: PhotosPickerItem?
    
    @State
    private var uiImageToSave: UIImage?
    
    @State
    private var imagePath: String?
    
    @State
    private var showCamera = false
    
    @State
    private var showScan = false
    
    @State
    private var showGalleryPicker = false
    
    @State
    private var showImageSourceDialog = false
    
    private var currentTotalComposition: Int {
        Int(selectedComposition.reduce(0) { $0 + $1.percentual })
    }
    
    private var isFormValid: Bool {
        let isNameValid = !name.trimmingCharacters(in: .whitespaces).isEmpty
        let isCompositionValid = currentTotalComposition <= 100
        
        return isNameValid && isCompositionValid
    }
    
    
    
    // MARK: - Alert Management
    
    @State
    private var alertErrorMessage: String = ""
    
    @State
    private var isAlertErrorVisible: Bool = false
    
    
    
    init(garment: Garment? = nil) {
        self.item            = garment
        
        _name                = State(initialValue: garment?.name ?? "")
        _brand               = State(initialValue: garment?.brand ?? "")
        
        var initialColor: Color
        if let hexString = garment?.color {
            initialColor = Color(hex: hexString)
            
        } else {
            initialColor = .accentColor
        }
        
        _color               = State(initialValue: initialColor)
        _wearCount           = State(initialValue: garment?.wearCount ?? 0)
        _selectedComposition = State(initialValue: garment?.composition ?? [])
        _selectedFabrics     = State(initialValue: Set(garment?.composition.map { $0.fabric } ?? []))
        
        _selectedCategory    = State(initialValue: garment?.category ?? .top)
        _selectedSubCategory = State(initialValue: garment?.subCategory ?? .top)
        _selectedSeason      = State(initialValue: garment?.season ?? .winter)
        _selectedStyle       = State(initialValue: garment?.style ?? .casual)
        _selectedState       = State(initialValue: garment?.state ?? nil)
        
        _washingSymbols      = State(initialValue: Set(garment?.washingSymbols ?? []))
        _purchaseDate        = State(initialValue: garment?.purchaseDate ?? .now)
        _imagePath           = State(initialValue: garment?.imagePath)
        
        
    }
    
    var body: some View {
                
        HeroListView(
            imagePath,
            previewImage    : uiImageToSave,
            isImageClicked  : $showImageSourceDialog,
            colorPlaceholder: color
        ) {
            
        } content: {
            // Section 1: Info
            self.sectionGeneralInfo
            
            // Section 2: Physical details
            self.sectionPhysicalDetails
            
            // Section 3: Care
            self.sectionCare
            
            // Section 4: Style & Category
            self.sectionStyleAndCategory
            
            // Section 5: Composition Garment
            self.sectionComposition
        }
        .navigationTitle(item == nil ? "New Garment" : "Edit Garment")
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
            isPresented: $showImageSourceDialog,
            actions: confirmationDialogHandler,
            message: { Text("Select how you want to add the photo") }
        )
        .sheet(
            isPresented: self.$showCamera,
            content    : sheetPhotoHandler
        )
        .sheet(
            isPresented: self.$showScan,
            content    : self.sheetScanHandler
        )
        .photosPicker(
            isPresented: self.$showGalleryPicker,
            selection  : self.$selectedItem,
            matching   : .images
        )
        .alert("Ops! Something went wrong", isPresented: $isAlertErrorVisible) {
            Button("Ok", role: .cancel) { }
            
        } message: {
            Text(alertErrorMessage)
        }
        .onChange(
            of: self.selectedFabrics,
            selectedFabricsChanged
        )
        .onChange(of: self.selectedCategory) { _, newValue in
            self.selectedSubCategory = newValue.subCategory.first ?? GarmentSubCategory.top
        }
        .onChange(
            of: self.selectedItem,
            self.selectedPhotoChanged
        )
    }
    
    // MARK: - Views
    
    
    
    @ViewBuilder
    var sectionGeneralInfo: some View {
        SectionList(titleKey: "Info Garment") {
            TextField("Name", text: self.$name)
            TextField("Brand", text: self.$brand)
            
            DatePicker(
                "Purchase Date",
                selection: self.$purchaseDate,
                displayedComponents: [.date]
            )
        }
    }
    
    
    
    @ViewBuilder
    var sectionPhysicalDetails: some View {
        SectionList(titleKey: "Details") {
            ColorPicker("Color", selection: self.$color)
            
            NavigationLink {
                GenericSelectionView<GarmentFabric>(
                    selection: self.$selectedFabrics
                )
                .navigationTitle("Fabrics")
                
            } label: {
                HStack {
                    Text("Fabrics")
                        .foregroundStyle(.primary)
                    
                    Spacer()
                    
                    HStack {
                        Text(self.selectedFabrics.isEmpty ? "None" : "\(self.selectedFabrics.count) selected")
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
    
    
    
    @ViewBuilder
    var sectionCare: some View {
        SectionList(titleKey: "Care") {
            NavigationLink {
                GenericSelectionView<LaundrySymbol>(
                    selection: self.$washingSymbols
                )
                .navigationTitle("Care Symbols")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Scan", systemImage: "camera.on.rectangle.fill") {
                            self.showScan = true
                        }
                        .fontWeight(.bold)
                    }
                }
                
            } label: {
                HStack {
                    Text("Washing Symbols")
                        .foregroundStyle(.primary)
                    
                    Spacer()
                    
                    HStack {
                        Text(self.washingSymbols.isEmpty ? "None" : "\(self.washingSymbols.count) selected")
                            .foregroundStyle(.tertiary)
                        
                        Image(systemName: "chevron.forward")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.tertiary)
                    }
                }
            }
            .tint(.primary)
            
            if self.selectedState != nil {
                PickerList("State", selection: self.$selectedState) {
                    ForEach(GarmentState.allCases, id: \.id) { state in
                        Text(state.rawValue).tag(state)
                    }
                }
                
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
    }
    
    
    
    @ViewBuilder
    var sectionStyleAndCategory: some View {
        SectionList(titleKey: "Style & Category") {
            
            PickerList("Type", selection: self.$selectedCategory) {
                ForEach(GarmentCategory.allCases, id: \.id) { type in
                    Text(type.label).tag(type)
                }
            }
            .pickerStyle(.menu)
            
            PickerList("Model", selection: self.$selectedSubCategory) {
                ForEach(self.selectedCategory.subCategory, id: \.id) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            .id(self.selectedCategory)
            .disabled(self.selectedCategory == .other)
            
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
        }
    }
    
    
    
    @ViewBuilder
    var sectionComposition: some View {
        if !selectedFabrics.isEmpty {
            SectionList(titleKey: "Composition") {
                
                VStack(alignment: .leading) {
                    HStack {
                        Text("Total")
                        
                        Spacer()
                        
                        Text("\(currentTotalComposition)%")
                            .foregroundColor(currentTotalComposition == 100 ? .green : (currentTotalComposition > 100 ? .red : .primary))
                            .fontWeight(.bold)
                    }
                    
                    ProgressView(value: Double(currentTotalComposition), total: 100)
                        .tint(currentTotalComposition == 100 ? .green : .orange)
                }
                .padding(.vertical, 15)
                
                ForEach(self.$selectedComposition, id: \.id) { $comp in
                    VStack(alignment: .leading) {
                        HStack {
                            Text(comp.fabric.rawValue)
                                .fontWeight(.medium)
                            
                            Spacer()
                            
                            Text("\(Int(comp.percentual))%")
                                .monospacedDigit()
                                .foregroundStyle(.secondary)
                        }
                        
                        Slider(
                            value: Binding<Double>(
                                get: { comp.percentual },
                                set: { newValue in
                                    
                                    let otherFabricsSum = self.selectedComposition
                                        .filter { $0.id != comp.id }
                                        .reduce(0) { $0 + $1.percentual }
                                    
                                    let availableSpace = 100.0 - otherFabricsSum
                                    
                                    
                                    $comp.wrappedValue.percentual = min(newValue, availableSpace)
                                }
                            ),
                            in: 0...100,
                            step: 1
                        )
                        .buttonStyle(.plain)

                    }
                    .padding(.vertical, 10)
                }
            }
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
        
        if self.imagePath != nil || self.uiImageToSave != nil {
            Button("Remove Photo", role: .destructive) {
                //self.selectedImage = nil
                self.uiImageToSave = nil
                self.imagePath     = nil
            }
        }
    }
    
    @ViewBuilder
    private func sheetPhotoHandler() -> some View {
        CameraView(
            onImageCaptured: { filename, image in
                self.uiImageToSave = image
                self.imagePath = (filename as NSString).lastPathComponent
            },
            mode: .photo
        )
        .ignoresSafeArea()
    }
    
    @ViewBuilder
    private func sheetScanHandler() -> some View {
        CameraView(
            onImageCaptured  : { _, _ in },
            onSymbolsCaptured: { symbols in
                for symbol in symbols {
                    if let icon = LaundrySymbol(createMLLabel: symbol) {
                        self.washingSymbols.insert(icon)
                    }
                }
            },
            mode: .recognizeSymbols
        )
        .ignoresSafeArea()
    }
    
    
    
    // MARK: - Handlers
    
    private func selectedFabricsChanged(
        _ oldValue: Set<GarmentFabric>,
        _ newValue: Set<GarmentFabric>
    ) {
        guard !newValue.isEmpty else {
            self.selectedComposition = []
            return
        }
        
        let keptFabrics = newValue.intersection(oldValue)
        let addedFabrics = newValue.subtracting(oldValue)
        
        var keptCompositions: [GarmentComposition] = []
        var currentKeptSum: Double = 0.0
        
        for fabric in keptFabrics {
            if let existing = self.selectedComposition.first(where: { $0.fabric == fabric }) {
                keptCompositions.append(existing)
                currentKeptSum += existing.percentual
            }
        }
        
        var newCompositionList: [GarmentComposition] = []
        
        if !addedFabrics.isEmpty {
            let availableSpace = 100.0 - currentKeptSum
            
            if availableSpace > 0.1 {
                let shareForNew = availableSpace / Double(addedFabrics.count)
                newCompositionList.append(contentsOf: keptCompositions)
                
                for fabric in addedFabrics {
                    newCompositionList.append(GarmentComposition(fabric: fabric, percentual: shareForNew))
                }
                
            } else {
                let equalShare         = 100.0 / Double(newValue.count)
                let totalSpaceForAdded = equalShare * Double(addedFabrics.count)
                let spaceForKept       = 100.0 - totalSpaceForAdded
                
                for var composition in keptCompositions {
                    if currentKeptSum > 0 {
                        composition.percentual = (composition.percentual / currentKeptSum) * spaceForKept
                        
                    } else {
                        composition.percentual = spaceForKept / Double(keptCompositions.count)
                    }
                    
                    newCompositionList.append(composition)
                }
                
                for fabric in addedFabrics {
                    newCompositionList.append(GarmentComposition(fabric: fabric, percentual: equalShare))
                }
            }
            
        } else {
            for var composition in keptCompositions {
                if currentKeptSum > 0 {
                    composition.percentual = (composition.percentual / currentKeptSum) * 100.0
                    
                } else {
                    composition.percentual = 100.0 / Double(keptCompositions.count)
                }
                
                newCompositionList.append(composition)
            }
        }
        
        self.selectedComposition = newCompositionList
    }
    
    private func selectedPhotoChanged(
        _ oldValue: PhotosPickerItem?,
        _ newValue: PhotosPickerItem?
    ) {
        Task {
            if let data = try? await self.selectedItem?.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                
                await MainActor.run {
                    self.uiImageToSave = uiImage
                    //self.selectedImage = Image(uiImage: uiImage)
                }
            }
        }
    }
    
    
    
    private func handleFinishAction() {
        let garmentToProcess: Garment?
        
        if self.item == nil {
            garmentToProcess = saveGarment()
            
        } else {
            garmentToProcess = updateGarment()            
            if let g = garmentToProcess {
                applianceManager.unassignGarment(g)
            }
        }

        if let finalGarment = garmentToProcess {
            applianceManager.processUnassignedGarments([finalGarment], laundrySessions)
            dismiss()
        }
    }
    
    
    
    private func saveGarment() -> Garment? {
        if let imageToSave = self.uiImageToSave {
            
            let result = ImageStorage.saveImage(imageToSave)
            switch result {
                case .success(let filename):
                    imagePath = (filename as NSString).lastPathComponent
                    
                case .failure(let error):
                    alertErrorMessage   = error.localizedDescription
                    isAlertErrorVisible = true
                    return nil
            }
        }
        
        let newGarment = Garment(
            name          : self.name,
            brand         : self.brand.isEmpty ? nil : self.brand,
            color         : self.color.toHex() ?? "nil",
            composition   : Array(self.selectedComposition),
            category      : self.selectedCategory,
            subCategory   : self.selectedSubCategory,
            season        : self.selectedSeason,
            style         : self.selectedStyle,
            purchaseDate  : self.purchaseDate,
            
            washingSymbols: Array(self.washingSymbols),
            
            imagePath     : self.imagePath
        )
                
        garmentManager.insert(newGarment)
        return newGarment
    }
    
    func updateGarment() -> Garment? {
        guard let garment = item else { return nil }
        
        if let imageToSave = self.uiImageToSave {
            
            if let oldPath = garment.imagePath {
                ImageStorage.deleteImage(filename: oldPath)
            }
            
            let result = ImageStorage.saveImage(imageToSave)
            switch result {
                case .success(let filename):
                    self.imagePath = (filename as NSString).lastPathComponent
                    
                case .failure(let error):
                    alertErrorMessage   = error.localizedDescription
                    isAlertErrorVisible = true
                    return nil
            }
        }
        
        garment.name           = self.name
        garment.brand          = self.brand.isEmpty ? nil : self.brand
        garment.color          = self.color.toHex() ?? "nil"
        
        // Updated properties
        garment.composition    = Array(self.selectedComposition)
        garment.category       = self.selectedCategory
        garment.subCategory    = self.selectedSubCategory
        garment.season         = self.selectedSeason
        garment.style          = self.selectedStyle
        garment.wearCount      = self.wearCount
        
        garment.washingSymbols = Array(self.washingSymbols)
        garment.purchaseDate   = self.purchaseDate
        garment.imagePath      = self.imagePath
        
        garmentManager.update()
        return garment
    }
}

#Preview {
    GarmentEditorView()
}
