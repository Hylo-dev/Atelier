//
//  WashGarmentView.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 12/03/26.
//

import SwiftUI

struct WashGarmentView: View {
    
    
    
    @Environment(\.dismiss)
    private var dismiss
        
    private static let column = [
        GridItem(.adaptive(minimum: 150), spacing: 20)
    ]
    
    
    
    let garments: [Garment]
    
    
    
    // MARK: - State selection variables
    
    @State
    private var isSelectionMode: Bool = false
    
    @State
    private var selectedGarments: Set<UUID> = []
    
    var body: some View {
        
        ScrollView {
            
            LazyVGrid(columns: Self.column, spacing: 20) {
                
                ForEach(garments, id: \.id) { garment in
                    let contained = selectedGarments.contains(garment.id)
                    
                    ModelCardView(
                        title     : garment.name,
                        imagePath : garment.imagePath,
                        isSelected: contained
                    )
                    .equatable()
                    .onTapGesture {
                        
                        if isSelectionMode {
                            
                            withAnimation {
                                if contained {
                                    selectedGarments.remove(garment.id)
                                    
                                } else {
                                    selectedGarments.insert(garment.id)
                                }
                            }
                            
                        }
                    }
                }
            }
        }
        .padding()
        .navigationTitle("Wash Garments")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            
            ToolbarItem(placement: .topBarLeading) {
                
                if isSelectionMode {
                    Button {
                        withAnimation {
                            selectedGarments = Set(garments.map(\.id))
                        }
                        
                    } label: {
                        Text("Select All")
                    }
                    
                } else {
                    Button {
                        dismiss()
                        
                    } label: {
                        Label("Dismiss", systemImage: "xmark")
                    }
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                
                if isSelectionMode {
                    Button() {
                        withAnimation {
                            isSelectionMode.toggle()
                            
                            if !isSelectionMode {
                                selectedGarments.removeAll()
                            }
                        }
                        
                    } label: {
                        Label("Cancel", systemImage: "xmark")
                    }
                    
                } else {
                    Button() {
                        withAnimation {
                            isSelectionMode.toggle()
                        }
                        
                    } label: {
                        Text("Select")
                    }
                }
            }

            
//            ToolbarItem(placement: .topBarTrailing) {
//                
//                Button(role: .confirm) {
//                    
//                } label: {
//                    Label("Confirm", systemImage: "checkmark")
//                }
//            }
        }
        
    }
}
