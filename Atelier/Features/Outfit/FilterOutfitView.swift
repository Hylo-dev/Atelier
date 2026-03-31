//
//  FilterOutfitView.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 25/02/26.
//

import SwiftUI

struct FilterOutfitView: View {
    
    @Environment(\.dismiss)
    var dismiss
    
    @Binding
    var filter: FilterOutfitConfig
    
    
    var body: some View {
        NavigationStack {
            Form {
                
                // MARK: Sections
                sectionAttributes
                
                sectionStatus
                
                sectionValue
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", systemImage: "xmark") {
                        self.dismiss()
                    }
                }
                
                if self.filter.isFiltering {
                    ToolbarItem {
                        Button("Reset", systemImage: "arrow.counterclockwise") {
                            withAnimation {
                                self.filter.reset()
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
            .onChange(of: self.filter.selectedOccasions) { _, newStyles in
                if let styles = newStyles, !styles.isEmpty && filter.onlyClean {
                    filter.onlyClean = false
                }
            }
        }
    }
    
    
    
    // MARK: - Subviews
    
    
    
    @ViewBuilder
    private var sectionAttributes: some View {
        Section("Attributes") {
            
            filterNavigationLink(
                title      : "Occasions",
                selection  : self.setBinding(
                    for: \.selectedOccasions
                ),
                destination: GenericSelectionView<GarmentStyle>(
                    selection: self.setBinding(for: \.selectedOccasions)
                )
            )
            
            filterNavigationLink(
                title      : "Seasons",
                selection  : self.setBinding(
                    for: \.selectedSeasons
                ),
                destination: GenericSelectionView<Season>(
                    selection: self.setBinding(for: \.selectedSeasons),
                    useSystemIcon: true
                )
            )
        }
        
    }
    
    @ViewBuilder
    private var sectionStatus: some View {
        Section("Status") {
            Toggle("Favorites Only", isOn: $filter.onlyFavorite)
            Toggle("Clean Only", isOn: self.$filter.onlyClean)
            Toggle("Recently Worn", isOn: self.$filter.recentWorn)
        }
    }
    
    
    @ViewBuilder
    private var sectionValue: some View {
        Section("Estimated Value") {
            HStack {
                Text("Max Price")
                Spacer()
                Text(filter.maxPrice.formatted(.currency(code: "EUR")))
                    .foregroundStyle(.secondary)
            }
            Slider(value: $filter.maxPrice, in: 0...5000, step: 50)
        }
    }
    
    
    
    // MARK: - Helpers
    
    private func setBinding<T>(
        for keyPath: WritableKeyPath<FilterOutfitConfig,
        Set<T>?>
    ) -> Binding<Set<T>> {
        Binding {
            self.filter[keyPath: keyPath] ?? []
            
        } set: { newValue in
            self.filter[keyPath: keyPath] = newValue.isEmpty ? nil : newValue
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
