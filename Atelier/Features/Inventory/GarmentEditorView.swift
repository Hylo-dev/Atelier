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
    
    @Environment(\.modelContext)
    private var modelContext
    
    @Environment(ApplianceManager.self)
    private var applianceManager
    
    @Query(
        sort : \LaundrySession.dateCreated,
        order: .forward
    )
    private var laundrySessions: [LaundrySession]
    
    @Binding
    var garmentManager: GarmentManager?
    
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
    private var selectedImage: Image?
    
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
    
    init(
        garmentManager: Binding<GarmentManager?>,
        garment       : Garment? = nil
    ) {
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
        
        if let garment = garment,
           let path = garment.imagePath,
           let image = ImageStorage.loadImage(from: path) {
            _selectedImage = State(initialValue: Image(uiImage: image))
        }
        
        self._garmentManager = garmentManager
    }
    
    var body: some View {
                
        HeroListView(
            imagePath,
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
                    let garmentToProcess: Garment
                    
                    if self.item == nil {
                        garmentToProcess = self.saveGarment()
                        
                    } else {
                        
                        self.updateGarment()
                        garmentToProcess = item!
                        applianceManager.unassignGarment(garmentToProcess)
                    }
                    
                    applianceManager.processUnassignedGarments(
                        [garmentToProcess],
                        laundrySessions
                    )
                    
                    dismiss()
                }
                .fontWeight(.bold)
                .disabled(self.name.isEmpty)
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
        .sheet(
            isPresented: self.$showScan,
            content    : self.sheetScanHandler
        )
        .photosPicker(
            isPresented: self.$showGalleryPicker,
            selection  : self.$selectedItem,
            matching   : .images
        )
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
                self.selectedImage = nil
                self.uiImageToSave = nil
                self.imagePath = nil
            }
        }
    }
    
    @ViewBuilder
    private func sheetPhotoHandler() -> some View {
        CameraView(
            onImageCaptured: { filename, image in
                self.selectedImage = Image(uiImage: image)
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

    
    private func selectedFabricsChanged(_ oldValue: Set<GarmentFabric>, _ newValue: Set<GarmentFabric>) {
        var newCompositionList: [GarmentComposition] = []
        
        for fabric in newValue {
            if let existing = self.selectedComposition.first(where: { $0.fabric == fabric }) {
                newCompositionList.append(existing)
                
            } else {
                newCompositionList.append(GarmentComposition(fabric: fabric, percentual: 0))
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
                
                self.uiImageToSave = uiImage
                self.selectedImage = Image(uiImage: uiImage)
                
                if let filename = ImageStorage.saveImage(uiImage) {
                    self.imagePath = filename
                }
            }
        }
    }
    
    
    // MARK: - Tools
    
    private var isFormValid: Bool {
        !self.name.isEmpty && self.color == Color.clear
    }
    
    private func saveGarment() -> Garment {
        
        if let imageToSave = self.uiImageToSave,
           let filename = ImageStorage.saveImage(imageToSave) {
            self.imagePath = (filename as NSString).lastPathComponent
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
                
        if let manager = self.garmentManager {
            manager.insert(newGarment)
            
        } else { print("Manager is nil") }
        
        return newGarment
    }
    
    func updateGarment() {
        
        if let imageToSave = self.uiImageToSave,
           let filename = ImageStorage.saveImage(imageToSave) {
            self.imagePath = (filename as NSString).lastPathComponent
        }
        
        self.item!.name           = self.name
        self.item!.brand          = self.brand.isEmpty ? nil : self.brand
        self.item!.color          = self.color.toHex() ?? "nil"
        
        // Updated properties
        self.item!.composition    = Array(self.selectedComposition)
        self.item!.category       = self.selectedCategory
        self.item!.subCategory    = self.selectedSubCategory
        self.item!.season         = self.selectedSeason
        self.item!.style          = self.selectedStyle
        self.item!.wearCount      = self.wearCount
        
        self.item!.washingSymbols = Array(self.washingSymbols)
        self.item!.purchaseDate   = self.purchaseDate
        self.item!.imagePath      = self.imagePath
        
        if let manager = self.garmentManager {
            manager.update()
            
        } else { print("Manager is nil") }
    }
}

#Preview {
    @Previewable
    @State
    var manager: GarmentManager? = nil
    
    GarmentEditorView(
        garmentManager: $manager
    )
}
