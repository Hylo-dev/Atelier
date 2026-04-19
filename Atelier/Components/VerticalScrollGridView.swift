//
//  VerticalScrollGridView.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 08/04/2026.
//

import SwiftUI
import SwiftData

struct VerticalScrollGridView<T: PersistentModel, Content: View>: View {
    private let items: [T]
    
    @ViewBuilder
    private var content: (T) -> Content
    
    private var insets: CGFloat
    
    private let columns = [
        GridItem(.adaptive(minimum: 150), spacing: 20)
    ]
    
    init(
        items  : [T],
        insets : CGFloat = 150,
        @ViewBuilder content: @escaping (T) -> Content
    ) {
        self.items   = items
        self.insets  = insets
        self.content = content
    }
    
    var body: some View {
        ScrollView(.vertical) {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(items, id: \.id) { item in
                    content(item)
                }
            }
            .padding(.horizontal, 16)
        }
        .contentMargins(.top, insets, for: .scrollContent)
        .scrollIndicators(.hidden)
    }
}
