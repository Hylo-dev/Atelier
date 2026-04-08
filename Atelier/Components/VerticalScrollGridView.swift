//
//  VerticalScrollGridView.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 08/04/2026.
//

import SwiftUI
import SwiftData

struct VerticalScrollGridView<T: PersistentModel, Content: View>: View {
    let items: [T]
    
    @ViewBuilder
    var content: (T) -> Content
    
    private let columns = [
        GridItem(.adaptive(minimum: 150), spacing: 20)
    ]
    
    init(
        items  : [T],
        @ViewBuilder content: @escaping (T) -> Content
    ) {
        self.items   = items
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
        .contentMargins(.top, 150, for: .scrollContent)
        .scrollIndicators(.hidden)
    }
}
