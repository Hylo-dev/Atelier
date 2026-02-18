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
    
    let brands: [String]
    
    var body: some View {
        NavigationStack {
            Form {
                
                Section("Categoria") {
                    
                    
                    
                    Picker(
                        "Seleziona",
                        selection: self.$filters.selectedCategory
                    ) {
                        
                        Text("Tutte").tag(nil as GarmentCategory?)
                        
                        ForEach(GarmentCategory.allCases) { cat in
                            Text(cat.rawValue).tag(cat as GarmentCategory?)
                        }
                    }
                }
                
                Section("Dettagli") {
                    Picker(
                        "Stagione",
                        selection: $filters.selectedSeason
                    ) {
                        
                        Text("Qualsiasi").tag(nil as Season?)
                        
                        ForEach(Season.allCases) { s in
                            Text(s.rawValue).tag(s as Season?)
                        }
                    }

                }
                
                Section("Stato") {
                    Toggle("Solo capi puliti", isOn: $filters.onlyClean)
                }
                
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", systemImage: "xmark") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done", systemImage: "checkmark") {
                        dismiss()
                    }
                }
            }
        }
    }
}
