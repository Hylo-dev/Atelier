//
//  GarmentSelectionView.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 17/02/26.
//

import SwiftUI
import SwiftData

struct GarmentSelectionView: View {
    
    @Binding
    var selectedGarments: Set<Garment>
    
    @Query(
        sort : \Garment.lastWashingDate,
        order: .reverse
    )
    private var garments: [Garment]
    
    @State
    private var isSelected: Bool = false
    
    static private let columns = [
        GridItem(.adaptive(minimum: 150), spacing: 20)
    ]
    
    var body: some View {
        
        ScrollView {
            if self.garments.isEmpty {
                ContentUnavailableView(
                    "Garments Empty",
                    systemImage: "hanger",
                    description: Text("Time to create your closet up")
                )
                .containerRelativeFrame(.vertical)
                
            } else { self.modelGridView }
        }
        .contentMargins(.horizontal, 16, for: .scrollContent)        
    }
    
    private var modelGridView: some View {
        LazyVGrid(columns: Self.columns, spacing: 20) {
            
            ForEach(self.garments, id: \.id) { item in
                let isSelected = self.selectedGarments.contains(item)

                
                ModelCardView(
                    title      : item.name,
                    subheadline: item.brand,
                    imagePath  : item.imagePath,
                    isSelected : isSelected
                )
                .equatable()
                .onTapGesture {
                    if self.selectedGarments.contains(item) {
                        self.selectedGarments.remove(item)
                        
                    } else {
                        self.selectedGarments.insert(item)
                        self.isSelected.toggle()
                    }
                }
                
                
            }
        }
        .sensoryFeedback(.selection, trigger: self.isSelected)
    }
}
