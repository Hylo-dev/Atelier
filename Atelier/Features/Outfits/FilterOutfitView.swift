//
//  FilterOutfitView.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 25/02/26.
//

import SwiftUI

struct FilterOutfitView: View {
    
    @Environment(\.dismiss)
    private var dismiss
    
    @Bindable
    var manager: FilterManager<FilterOutfitConfig>
    
    var body: some View {
        NavigationStack {
            Form {
                // SECTION 1: STYLE & OCCASION (Pills)
                Section("Style & Occasion") {
                    VStack(alignment: .leading, spacing: 0) {
                        filterHorizontalScroll(title: "Seasons") {
                            ForEach(Season.allCases, id: \.self) { season in
                                PillFilter(
                                    item: season,
                                    selection: $manager.config.selectedSeasons
                                )
                                .equatable()
                            }
                        }
                        
                        Divider()
                            .padding(.leading)
                        
                        filterHorizontalScroll(title: "Occasions") {
                            ForEach(GarmentStyle.allCases, id: \.self) { style in
                                PillFilter(
                                    item: style,
                                    selection: $manager.config.selectedOccasions
                                )
                                .equatable()
                            }
                        }
                    }
                    .listRowInsets(EdgeInsets())
                }
                
                // SECTION 2: COLOR ANALYSIS
                Section("Color & Tone") {
                    Picker("Tone", selection: $manager.config.selectedTone) {
                        ForEach(Tone.allCases, id: \.self) { tone in
                            Text(tone.rawValue.capitalized).tag(tone)
                        }
                    }
                    .tint(.secondary)
                    
//                    colorLink
                }
                
                // SECTION 3: STATUS
                Section("Status") {
                    Toggle("Favorites Only", isOn: $manager.config.onlyFavorite)
                    Toggle("Clean Only", isOn: $manager.config.onlyClean)
                    Toggle("Recently Worn", isOn: $manager.config.recentWorn)
                }
                
                // SECTION 4: VALUE
                Section("Estimated Value") {
                    VStack(spacing: 8) {
                        HStack {
                            Text("Max Price")
                            Spacer()
                            Text(manager.config.maxPrice == 0 ? "All" : manager.config.maxPrice.formatted(.currency(code: "EUR")))
                                .foregroundStyle(.secondary)
                        }
                        Slider(value: $manager.config.maxPrice, in: 0...5000, step: 50)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", systemImage: "xmark") { dismiss() }
                }
                
                if manager.isFiltering {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Reset", systemImage: "arrow.counterclockwise") {
                            withAnimation { manager.resetFilters() }
                        }
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done", systemImage: "checkmark") { dismiss() }
                        .fontWeight(.bold)
                }
            }
            // Logica di business: se selezioni un'occasione, disabilita il filtro "solo puliti" (o viceversa)
            .onChange(of: manager.config.selectedOccasions) { _, newValue in
                if let val = newValue, !val.isEmpty && manager.config.onlyClean {
                    manager.config.onlyClean = false
                }
            }
        }
    }
    
    // MARK: - Sublinks & Helpers
    
//    private var colorLink: some View {
//        NavigationLink {
//            ColorSelectionView(selection: $manager.config.selectedColors.unwrappedSet())
//                .navigationTitle("Dominant Colors")
//        } label: {
//            HStack {
//                Text("Colors")
//                Spacer()
//                if manager.config.selectedColors.isEmpty {
//                    Text("All").foregroundStyle(.secondary)
//                } else {
//                    HStack(spacing: 4) {
//                        ForEach(Array(manager.config.selectedColors).prefix(3), id: \.self) { color in
//                            Circle()
//                                .fill(color)
//                                .frame(width: 12, height: 12)
//                        }
//                        if manager.config.selectedColors.count > 3 {
//                            Text("+\(manager.config.selectedColors.count - 3)")
//                                .font(.caption2)
//                                .foregroundStyle(.accent)
//                        }
//                    }
//                }
//            }
//        }
//    }
    
    @ViewBuilder
    private func filterHorizontalScroll<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 15)
                .padding(.top, 10)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 12) {
                    content()
                }
                .padding(.horizontal, 15)
                .padding(.bottom, 12)
            }
        }
    }
}

