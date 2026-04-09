//
//  FilterSheetView.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 18/02/26.
//

import SwiftUI

struct FilterGarmentView: View {
    @Environment(\.dismiss)
    var dismiss
    
    @Binding
    var filters: FilterGarmentConfig
    
    var brands: [String]
    
    var body: some View {
        NavigationStack {
            Form {
                
                Section("Style & Season") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 13) {
                            ForEach(Season.allCases, id: \.self) { season in
                                PillFilter(
                                    item: season,
                                    selection: $filters.selectedSeason
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
                                    selection: $filters.selectedStyle
                                )
                            }
                        }
                        .padding(15)
                    }
                    .listRowInsets(EdgeInsets())
                    
                }
                
                if brands.count > 1 || filters.selectedSubCategory != nil {
                    Section("Identity") {
                        if brands.count > 1 {
                            brandLink
                        }
                        
                        modelLink
                    }
                }
                
                // SECTION 3: CONDITION & CARE
                Section("Condition & Care") {
                    conditionLink
                    Toggle("Show Clean Only", isOn: $filters.onlyClean)
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close", systemImage: "xmark") { dismiss() }
                }
                
                if filters.isFiltering {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Reset", systemImage: "arrow.trianglehead.clockwise") {
                            withAnimation { filters.reset() }
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
            StringSelectionView(title: "Brand", items: brands, selection: setBinding(for: \.selectedBrand))
        } label: {
            filterRow(title: "Brand", count: filters.selectedBrand?.count ?? 0)
        }
    }
    
    private var modelLink: some View {
        NavigationLink {
            GenericSelectionView<GarmentSubCategory>(selection: setBinding(for: \.selectedSubCategory))
        } label: {
            filterRow(title: "Model", count: filters.selectedSubCategory?.count ?? 0)
        }
    }
    
    private var conditionLink: some View {
        NavigationLink {
            GenericSelectionView<GarmentState>(selection: setBinding(for: \.selectedCondition))
        } label: {
            filterRow(title: "Condition", count: filters.selectedCondition?.count ?? 0)
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
    
    private func setBinding<T>(for keyPath: WritableKeyPath<FilterGarmentConfig, Set<T>?>) -> Binding<Set<T>> {
        Binding {
            self.filters[keyPath: keyPath] ?? []
        } set: {
            self.filters[keyPath: keyPath] = $0.isEmpty ? nil : $0
        }
    }
}

struct PillFilter<T: RawRepresentable & Hashable & Identifiable>: View where T.RawValue == String {
    let item: T
    
    @Binding
    var selection: Set<T>?
    
    var body: some View {
        let isSelected = selection?.contains(item) ?? false
        
        Text(item.rawValue.capitalized)
            .font(.system(size: 14, weight: .medium))
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                isSelected ? Color.accentColor : Color(.tertiarySystemFill)
            )
            .foregroundStyle(isSelected ? .white : .primary)
            .clipShape(Capsule())
            .onTapGesture {
                var currentSet = selection ?? []
                
                if currentSet.contains(item) {
                    currentSet.remove(item)
                } else {
                    currentSet.insert(item)
                }
                
                withAnimation {
                    selection = currentSet.isEmpty ? nil : currentSet
                }
            }
    }
}
