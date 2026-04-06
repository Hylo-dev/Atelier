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
                sectionColorAnalysis
                
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
                
                Group {
                    if filter.maxPrice == 0 {
                        Text("All")
                        
                    } else {
                        Text(
                            filter.maxPrice.formatted(
                                .currency(code: "EUR")
                            )
                        )
                    }
                }
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
    
    @ViewBuilder
    private var sectionColorAnalysis: some View {
        Section("Color & Tone") {

            Picker("Tone", selection: $filter.selectedTone) {
                ForEach(Tone.allCases, id: \.rawValue) { tone in
                    Text(tone.rawValue)
                        .tag(tone)
                }
            }
            .padding(.vertical, 5)
            .tint(.secondary)
            
//            NavigationLink {
//                ColorSelectionView(selection: $filter.selectedColors)
//                    .navigationTitle("Dominant Colors")
//            } label: {
//                LabeledContent("Colors") {
//                    if filter.selectedColors.isEmpty {
//                        Text("All")
//                            .foregroundStyle(.secondary)
//                    } else {
//                        HStack(spacing: 4) {
//                            ForEach(Array(filter.selectedColors).prefix(3), id: \.self) { color in
//                                Circle()
//                                    .fill(color)
//                                    .frame(width: 12, height: 12)
//                            }
//                            if filter.selectedColors.count > 3 {
//                                Text("+\(filter.selectedColors.count - 3)")
//                                    .font(.caption2)
//                            }
//                        }
//                    }
//                }
//            }
        }
    }
}
