//
//  FilterSheetView.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 18/02/26.
//

import SwiftUI
import SwiftData

struct FilterGarmentView: View {
    @Environment(\.dismiss)
    private var dismiss
    
    @Bindable
    private var manager: FilterManager<FilterGarmentConfig>
    
    let brands: [String]
    
    init(
        manager: FilterManager<FilterGarmentConfig>,
        brands : [String]
    ) {
        self.manager = manager
        self.brands  = brands
    }
    
    var body: some View {
        NavigationStack {
            Form {
                
                Section("Style & Season") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 13) {
                            ForEach(Season.allCases, id: \.self) { season in
                                PillFilter(
                                    item: season,
                                    selection: $manager.config.selectedSeason
                                )
                            }
                        }
                        .padding(15)
                    }
                    .listRowInsets(EdgeInsets())
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 13) {
                            ForEach(GarmentStyle.allCases, id: \.self) { style in
                                PillFilter(
                                    item: style,
                                    selection: $manager.config.selectedStyle
                                )
                                .equatable()
                            }
                        }
                        .padding(15)
                    }
                    .listRowInsets(EdgeInsets())
                    
                }
                
                Section("Identity") {
                    if brands.count > 1 ||
                        manager.config.selectedBrand != nil {
                        
                        brandLink
                    }
                    
                    modelLink
                }
                
                // SECTION 3: CONDITION & CARE
                Section("Condition & Care") {
                    conditionLink
                    Toggle("Show Clean Only", isOn: $manager.config.onlyClean)
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close", systemImage: "xmark") { dismiss() }
                }
                
                if manager.isFiltering {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Reset", systemImage: "arrow.trianglehead.clockwise") {
                            withAnimation { manager.resetFilters() }
                        }
                    }
                    
                    ToolbarSpacer()
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done", systemImage: "checkmark") { dismiss() }
                        .fontWeight(.bold)
                }
            }
        }
    }
    
    
    
    // MARK: - Sublinks
    
    private var brandLink: some View {
        NavigationLink {
            StringSelectionView(
                title: "Brand",
                items: brands,
                selection: $manager.config.selectedBrand.unwrappedSet()
            )
        } label: {
            filterRow(title: "Brand", count: manager.config.selectedBrand?.count ?? 0)
        }
    }
    
    private var modelLink: some View {
        NavigationLink {
            GenericSelectionView<GarmentSubCategory>(
                selection: $manager.config.selectedSubCategory.unwrappedSet()
            )
        } label: {
            filterRow(title: "Model", count: manager.config.selectedSubCategory?.count ?? 0)
        }
    }
    
    private var conditionLink: some View {
        NavigationLink {
            GenericSelectionView<GarmentState>(
                selection: $manager.config.selectedCondition.unwrappedSet()
            )
        } label: {
            filterRow(title: "Condition", count: manager.config.selectedCondition?.count ?? 0)
        }
    }
    
    private func filterRow(title: String, count: Int) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(count == 0 ? "All" : "\(count) selected")
                .foregroundStyle(count == 0 ? .secondary : Color.accentColor)
        }
    }
}


extension Binding {
    func unwrappedSet<T>() -> Binding<Set<T>> where Value == Set<T>? {
        Binding<Set<T>>(
            get: { self.wrappedValue ?? [] },
            set: { self.wrappedValue = $0.isEmpty ? nil : $0 }
        )
    }
}
