//
//  ModifyGarmentView.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 17/02/26.
//

import SwiftUI
import PhotosUI
import UIKit

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
    private var selectedState: GarmentState
    
    
    
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
    private var showGalleryPicker = false
    
    @State
    private var showImageSourceDialog = false
    
    @State
    private var showScan = false
    
    private var currentTotalComposition: Int {
        Int(selectedComposition.reduce(0) { $0 + $1.percentual })
    }
    
    init(
        garmentManager: Binding<GarmentManager?>,
        garment       : Garment
    ) {
        self.item            = garment
        
        _name                = State(initialValue: garment.name)
        _brand               = State(initialValue: garment.brand ?? "")
        _color               = State(initialValue: Color(hex: garment.color))
        
        _selectedComposition = State(initialValue: garment.composition)
        _selectedFabrics     = State(initialValue: Set(garment.composition.map { $0.fabric }))
        
        _selectedCategory    = State(initialValue: garment.category)
        _selectedSubCategory = State(initialValue: garment.subCategory)
        _selectedSeason      = State(initialValue: garment.season)
        _selectedStyle       = State(initialValue: garment.style)
        _selectedState       = State(initialValue: garment.state)
        
        _washingSymbols      = State(initialValue: Set(garment.washingSymbols))
        _purchaseDate        = State(initialValue: garment.purchaseDate)
        _imagePath           = State(initialValue: garment.imagePath)
        
        if let path = garment.imagePath, let image = ImageStorage.loadImage(from: path) {
            _selectedImage = State(initialValue: Image(uiImage: image))
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
            
            // MARK: - Sections
            
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
        .navigationTitle("Edit garment")
        .navigationBarTitleDisplayMode(.inline)
        .scrollDismissesKeyboard(.interactively)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", systemImage: "xmark") { dismiss() }
            }
            
            ToolbarItem(placement: .confirmationAction) {
                Button("Finish", systemImage: "checkmark") {
                    self.updateGarment()
                }
                .fontWeight(.bold)
                .disabled(self.name.isEmpty)
            }
        }
        .confirmationDialog(
            "Choose Image",
            isPresented: self.$showImageSourceDialog,
            actions: self.confirmationDialogHandler,
            message: { Text("Select how you want to add the photo") }
        )
        .sheet(
            isPresented: self.$showCamera,
            content    : self.sheetHandler
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
            of: self.selectedItem,
            selectedItemChanged
        )
        .onChange(
            of: self.selectedFabrics,
            selectedFabricsChanged
        )
        .onChange(of: self.selectedCategory) { _, newValue in
            self.selectedSubCategory = newValue.subCategory.first ?? GarmentSubCategory.top
        }
    }
    
    // MARK: - Views
    
    @ViewBuilder
    private var avatarView: some View {
        Group {
            if let path = self.imagePath, let image = ImageStorage.loadImage(from: path) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(self.color.gradient)
                    
                    Image(systemName: "hanger")
                        .font(.system(size: 80))
                        .foregroundStyle(.white.opacity(0.5))
                }
            }
        }
        .frame(width: 260)
        .aspectRatio(3/4, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
    }
    
    @ViewBuilder
    var sectionGeneralInfo: some View {
        Section("Info Garment") {
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
        Section("Details") {
            ColorPicker("Color", selection: self.$color)
            
            NavigationLink {
                GenericSelectionView<GarmentFabric>(selection: self.$selectedFabrics)
                    .navigationTitle("Fabrics")
                
            } label: {
                HStack {
                    Text("Fabrics")
                    
                    Spacer()
                    
                    Text(self.selectedFabrics.isEmpty ? "None" : "\(self.selectedFabrics.count) selected")
                        .foregroundStyle(.secondary)
                    
                }
            }
        }
    }
    
    @ViewBuilder
    var sectionCare: some View {
        Section("Care") {
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
                    
                    Spacer()
                    
                    Text(self.washingSymbols.isEmpty ? "None" : "\(self.washingSymbols.count) selected")
                        .foregroundStyle(.secondary)
                }
            }
            
            Picker("State", selection: self.$selectedState) {
                ForEach(GarmentState.allCases, id: \.id) { state in
                    Text(state.rawValue).tag(state)
                    
                }
            }
        }
    }
    
    @ViewBuilder
    var sectionStyleAndCategory: some View {
        Section("Style & Category") {
            
            Picker("Type", selection: self.$selectedCategory) {
                ForEach(GarmentCategory.allCases, id: \.id) { type in
                    Text(type.label).tag(type)
                }
            }
            
            Picker("Model", selection: self.$selectedSubCategory) {
                ForEach(self.selectedCategory.subCategory, id: \.id) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            .id(self.selectedCategory)
            .disabled(self.selectedCategory == .other)
            
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
        }
    }
    
    @ViewBuilder
    var sectionComposition: some View {
        if !selectedFabrics.isEmpty {
            Section("Composition") {
                
                VStack(alignment: .leading) {
                    HStack {
                        Text("Total")
                        
                        Spacer()
                        
                        Text("\(self.currentTotalComposition)%")
                            .foregroundColor(self.currentTotalComposition == 100 ? .green : (self.currentTotalComposition > 100 ? .red : .primary))
                            .fontWeight(.bold)
                    }
                    
                    ProgressView(value: Double(self.currentTotalComposition), total: 100)
                        .tint(self.currentTotalComposition == 100 ? .green : .orange)
                }
                .padding(.vertical, 5)
                
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
                                    
                                    comp.percentual = min(newValue, availableSpace)
                                }
                            ),
                            in: 0...100,
                            step: 1
                        )
                        .buttonStyle(.plain)
                    }
                    .padding(.vertical, 4)
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
                    self.imagePath = filename
                }
            }
        }
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
    
    func updateGarment() {
        
        self.item.name           = self.name
        self.item.brand          = self.brand.isEmpty ? nil : self.brand
        self.item.color          = self.color.toHex() ?? "nil"
        
        // Updated properties
        self.item.composition    = Array(self.selectedComposition)
        self.item.category       = self.selectedCategory
        self.item.subCategory    = self.selectedSubCategory
        self.item.season         = self.selectedSeason
        self.item.style          = self.selectedStyle
        
        self.item.washingSymbols = Array(self.washingSymbols)
        self.item.purchaseDate   = self.purchaseDate
        self.item.imagePath      = self.imagePath ?? ""
        
        
        if let manager = self.garmentManager {
            manager.updateGarment()
            
        } else { print("Manager is nil") }
        
        dismiss()
    }
}
