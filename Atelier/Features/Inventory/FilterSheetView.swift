//
//  FilterSheetView.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 18/02/26.
//

import SwiftUI

struct FilterSheetView: View {
    
    @Environment(\.dismiss)
    var dismiss
    
    @Binding
    var filters: FilterGarmentConfig
    
    @Binding
    var brands: [String]
    
    var body: some View {
        NavigationStack {
            Form {
                
                // MARK: - Section 1
                self.detailsSection
                
                // MARK: - Section 2
                self.syleAndCategorySection
                
                // MARK: - Stato
                self.careSection
                
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close", systemImage: "xmark") {
                        dismiss()
                    }
                }
                
                if filters.isFiltering {
                    ToolbarItem {
                        Button("Reset", systemImage: "arrow.counterclockwise") {
                            withAnimation {
                                self.filters.reset()
                            }
                        }
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done", systemImage: "checkmark") {
                        dismiss()
                    }
                    .fontWeight(.bold)
                }
            }
            .onChange(of: self.filters.selectedState) { _, newStates in
                if let states = newStates, !states.isEmpty && self.filters.onlyClean{
                    self.filters.onlyClean = false
                }
            }
        }
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    private var detailsSection: some View {
        if !self.brands.isEmpty {
            
            Section("Details Garment") {
                let selected = Binding<Set<String>>(
                    get: { self.filters.selectedBrand ?? [] },
                    set: { newSet in
                        self.filters.selectedBrand = newSet.isEmpty ? nil : newSet
                    }
                )
                
                
                NavigationLink {
                    StringSelectionView(
                        title    : "Brand",
                        items    : self.brands,
                        selection: selected
                    )
                    .navigationTitle("Brand")
                    
                } label: {
                    HStack {
                        Text("Brand")
                        
                        Spacer()
                        
                        if selected.wrappedValue.isEmpty {
                            Text("All")
                                .foregroundStyle(.secondary)
                            
                        } else {
                            Text("\(selected.wrappedValue.count) selected")
                                .foregroundStyle(Color.accentColor)
                                .fontWeight(.medium)
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private var syleAndCategorySection: some View {
        Section("Style & Category") {
            
            self.filterNavigationLink(
                title      : "Model",
                selection  : self.setBinding(for: \.selectedSubCategory),
                destination: GenericSelectionView<GarmentSubCategory>(
                    selection: self.setBinding(for: \.selectedSubCategory)
                )
            )
            
            self.filterNavigationLink(
                title      : "Season",
                selection  : self.setBinding(for: \.selectedSeason),
                destination: GenericSelectionView<Season>(
                    selection    : self.setBinding(for: \.selectedSeason),
                    useSystemIcon: true
                )
            )
            
            self.filterNavigationLink(
                title      : "Style",
                selection  : self.setBinding(for: \.selectedStyle),
                destination: GenericSelectionView<GarmentStyle>(
                    selection: self.setBinding(for: \.selectedStyle)
                )
            )
        }
        
    }
    
    @ViewBuilder
    private var careSection: some View {
        Section("Care") {
            Toggle("Only garment clean", isOn: self.$filters.onlyClean)
            
            self.filterNavigationLink(
                title      : "State",
                selection  : self.setBinding(for: \.selectedState),
                destination: GenericSelectionView<GarmentState>(
                    selection: self.setBinding(for: \.selectedState)
                )
            )
        }
    }
    
    // MARK: - Helpers
    
    private func setBinding<T>(
        for keyPath: WritableKeyPath<FilterGarmentConfig,
        Set<T>?>
    ) -> Binding<Set<T>> {
        Binding {
            self.filters[keyPath: keyPath] ?? []
        } set: { newValue in
            self.filters[keyPath: keyPath] = newValue.isEmpty ? nil : newValue
        }
    }
    
    @ViewBuilder
    private func filterNavigationLink<T, Destination: View>(
        title      : String,
        selection  : Binding<Set<T>>,
        destination: Destination
    ) -> some View {
        
        NavigationLink {
            destination
                .navigationTitle(title)
        } label: {
            HStack {
                Text(title)
                
                Spacer()
                
                if selection.wrappedValue.isEmpty {
                    Text("All")
                        .foregroundStyle(.secondary)
                    
                } else {
                    Text("\(selection.wrappedValue.count) selected")
                        .foregroundStyle(Color.accentColor)
                        .fontWeight(.medium)
                }
            }
        }
    }
}
