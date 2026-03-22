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
                self.syleAndCategorySection
                
                self.careSection
                
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close", systemImage: "xmark") {
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
            .onChange(of: self.filter.selectedStyle) { _, newStyles in
                if let styles = newStyles, !styles.isEmpty && self.filter.onlyClean {
                    self.filter.onlyClean = false
                }
            }
        }
    }
    
    
    
    // MARK: - Subviews
    
    
    
    @ViewBuilder
    private var syleAndCategorySection: some View {
        Section("Style") {
            
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
            Toggle("Only garment clean", isOn: self.$filter.onlyClean)
            
            Toggle("Recent Worn outfits", isOn: self.$filter.recentWorn)
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
