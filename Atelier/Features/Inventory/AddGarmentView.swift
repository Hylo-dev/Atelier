//
//  AddGarmentView.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 16/02/26.
//

import SwiftUI
import PhotosUI
import UIKit

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
    private var color: Color = Color.accentColor
    
    
    
    @State
    private var selectedFabrics: Set<GarmentFabric> = []
    
    @State
    private var selectedComposition: [GarmentComposition] = []
    
    @State
    private var selectedCategory: GarmentCategory = .top
    
    @State
    private var selectedSubCategory: GarmentSubCategory = .top
    
    @State
    private var selectedSeason: Season = .summer
    
    @State
    private var selectedStyle: GarmentStyle = .elegant
    
    
    
    @State
    private var washingSymbols: Set<LaundrySymbol> = []
    
    @State
    private var purchaseDate: Date = .now
    
    
    
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
    
    var body: some View {
        
        ScrollView {
            
            VStack {
                self.heroImageSection
                
                // MARK: - Sections
                
                LazyVStack(spacing: 26) {
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
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
        }
        .ignoresSafeArea()
        .navigationTitle("New garment")
        .navigationBarTitleDisplayMode(.inline)
        .scrollDismissesKeyboard(.interactively)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", systemImage: "xmark") { dismiss() }
            }
            
            ToolbarItem(placement: .confirmationAction) {
                Button("Finish", systemImage: "checkmark") {
                    self.saveGarment()
                    
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
    private var heroImageSection: some View {
        
        GeometryReader { proxy in
            let minY = proxy.frame(in: .global).minY
            let isScrollingDown = minY > 0

            AvatarView(
                self.imagePath ?? "",
                color: self.color,
                icon : "hanger",
                uiImage: self.uiImageToSave
            )
            .frame(
                width: proxy.size.width,
                height: proxy.size.height + (isScrollingDown ? minY : 0)
            )
            .offset(y: isScrollingDown ? -minY : 0)
        }
        .frame(height: 560)
        .overlay(alignment: .bottom) {
            LinearGradient(
                stops: [
                    .init(color: Color(uiColor: .systemBackground), location: 0),
                    .init(color: Color(uiColor: .systemBackground).opacity(0.9), location: 0.2),
                    .init(color: Color(uiColor: .systemBackground).opacity(0.5), location: 0.5),
                    .init(color: Color(uiColor: .systemBackground).opacity(0.2), location: 0.8),
                    .init(color: .clear, location: 1.0)
                ],
                startPoint: .bottom,
                endPoint  : .top
            )
            .frame(height: 300)
            .allowsHitTesting(false)
        }
        .onTapGesture {
            self.showImageSourceDialog = true
        }
        
    }
    
    
    
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
                            .foregroundStyle(.secondary)
                        
                        Image(systemName: "chevron.forward")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
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
                            .foregroundStyle(.secondary)
                        
                        Image(systemName: "chevron.forward")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .tint(.primary)
            
            
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
                                    
                                    
                                    $comp.wrappedValue.percentual = min(newValue, availableSpace)
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
    
    
    
    // MARK: - Tools
    
    private var isFormValid: Bool {
        !self.name.isEmpty && self.color == Color.clear
    }
    
    private func saveGarment() {
        
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
            manager.addGarment(newGarment)
            
        } else { print("Manager is nil") }
        
        dismiss()
    }
}

#Preview {
    @Previewable
    @State
    var manager: GarmentManager? = nil
    
    AddGarmentView(
        garmentManager: $manager
    )
}
