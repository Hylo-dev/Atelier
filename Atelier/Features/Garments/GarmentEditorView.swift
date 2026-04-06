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
    private var editorViewModel: GarmentEditorViewModel
    
    
    
    // MARK: - Image Handling States
    
    @State
    private var uiImageToSave: UIImage?
    
    @State
    private var showCamera = false
    
    @State
    private var showScan = false
    
    
    
    init(garment: Garment? = nil) {
        self.item = garment
        self._editorViewModel = State(
            initialValue: GarmentEditorViewModel(garment)
        )
    }
    
    var body: some View {
                
        HeroListView(
            editorViewModel.imagePath,
            previewImage    : uiImageToSave,
            isImageClicked  : $showCamera,
            colorPlaceholder: [editorViewModel.color]
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
                    editorViewModel.handleFinishAction(
                        item,
                        image           : uiImageToSave,
                        manager         : garmentManager,
                        applianceManager: applianceManager,
                        sessions        : laundrySessions
                    ) { dismiss() }
                }
                .fontWeight(.bold)
                .disabled(!editorViewModel.isFormValid)
            }
        }
        .fullScreenCover(
            isPresented: self.$showCamera,
            content    : sheetPhotoHandler
        )
        .sheet(
            isPresented: self.$showScan,
            content    : self.sheetScanHandler
        )
        .alert("Ops! Something went wrong", isPresented: $editorViewModel.isAlertErrorVisible) {
            Button("Ok", role: .cancel) { }
            
        } message: {
            Text(editorViewModel.alertErrorMessage)
        }
        .onChange(
            of: editorViewModel.selectedFabrics,
            editorViewModel.selectedFabricsChanged
        )
        .onChange(of: editorViewModel.selectedCategory) { _, newValue in
            editorViewModel.selectedSubCategory = newValue.subCategory.first ?? GarmentSubCategory.top
        }
    }
    
    
    
    // MARK: - Views
        
    @ViewBuilder
    var sectionGeneralInfo: some View {
        SectionList(titleKey: "Info Garment") {
            TextField("Name", text: $editorViewModel.name)
            TextField("Brand", text: $editorViewModel.brand)
            TextField(
                "Price",
                value: $editorViewModel.price,
                format: .currency(
                    code: Locale.current.currency?.identifier ?? "EUR"
                )
            )
            .keyboardType(.decimalPad)
            
            DatePicker(
                "Purchase Date",
                selection: $editorViewModel.purchaseDate,
                displayedComponents: [.date]
            )
        }
    }
    
    
    
    @ViewBuilder
    var sectionPhysicalDetails: some View {
        SectionList(titleKey: "Details") {
            ColorPicker("Color", selection: $editorViewModel.color)
            
            NavigationLink {
                GenericSelectionView<GarmentFabric>(
                    selection: $editorViewModel.selectedFabrics
                )
                .navigationTitle("Fabrics")
                
            } label: {
                HStack {
                    Text("Fabrics")
                        .foregroundStyle(.primary)
                    
                    Spacer()
                    
                    HStack {
                        Text(editorViewModel.selectedFabrics.isEmpty ? "None" : "\(editorViewModel.selectedFabrics.count) selected")
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
                    selection: $editorViewModel.washingSymbols
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
                        Text(editorViewModel.washingSymbols.isEmpty ? "None" : "\(editorViewModel.washingSymbols.count) selected")
                            .foregroundStyle(.tertiary)
                        
                        Image(systemName: "chevron.forward")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.tertiary)
                    }
                }
            }
            .tint(.primary)
            
            if editorViewModel.selectedState != nil {
                PickerList("State", selection: $editorViewModel.selectedState) {
                    ForEach(GarmentState.allCases, id: \.id) { state in
                        Text(state.rawValue).tag(state)
                    }
                }
                
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
    }
    
    
    
    @ViewBuilder
    var sectionStyleAndCategory: some View {
        SectionList(titleKey: "Style & Category") {
            
            PickerList("Type", selection: $editorViewModel.selectedCategory) {
                ForEach(GarmentCategory.allCases, id: \.id) { type in
                    Text(type.label).tag(type)
                }
            }
            .pickerStyle(.menu)
            
            PickerList("Model", selection: $editorViewModel.selectedSubCategory) {
                ForEach(editorViewModel.selectedCategory.subCategory, id: \.id) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            .id(editorViewModel.selectedCategory)
            .disabled(editorViewModel.selectedCategory == .other)
            
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
        }
    }
    
    
    
    @ViewBuilder
    var sectionComposition: some View {
        if !editorViewModel.selectedFabrics.isEmpty {
            SectionList(titleKey: "Composition") {
                
                VStack(alignment: .leading) {
                    let composition = editorViewModel.currentTotalComposition
                    HStack {
                        Text("Total")
                        
                        Spacer()
                        
                        Text("\(composition)%")
                            .foregroundColor(composition == 100 ? .green : (composition > 100 ? .red : .primary))
                            .fontWeight(.bold)
                    }
                    
                    ProgressView(value: Double(composition), total: 100)
                        .tint(composition == 100 ? .green : .orange)
                }
                .padding(.vertical, 15)
                
                ForEach($editorViewModel.selectedComposition, id: \.id) { $comp in
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
                                    
                                    let otherFabricsSum = editorViewModel.selectedComposition
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
    
    
    
    // MARK: - Views handlers
    
    @ViewBuilder
    private func sheetPhotoHandler() -> some View {
        NavigationStack {
            CameraContainerView(mode: .photo(removeBackground: true)) { filename, image in
                self.uiImageToSave = image
                editorViewModel.imagePath = (filename as NSString).lastPathComponent                
            }
        }
    }
    
    
    @ViewBuilder
    private func sheetScanHandler() -> some View {
        
        CameraContainerView(
            mode: .recognizeSymbols,
            onSymbolsCaptured: { symbols in
                for symbol in symbols {
                    if let icon = LaundrySymbol(createMLLabel: symbol) {
                        editorViewModel.washingSymbols.insert(icon)
                    }
                }
            }
        ) { _, _ in }
    }
}

#Preview {
    GarmentEditorView()
}
