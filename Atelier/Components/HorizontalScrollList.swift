//
//  HorizontalScrollList.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 08/04/2026.
//

import SwiftUI
import SwiftData

struct HorizontalScrollList<T: PersistentModel, Content: View>: View {
    let title: String
    let items: [T]
    
    @ViewBuilder
    var content: (T) -> Content
    
    init(
        title: String,
        items: [T],
        @ViewBuilder content: @escaping (T) -> Content
    ) {
        self.title   = title
        self.items   = items
        self.content = content
    }
    
    var body: some View {
        SectionList(titleKey: title) {
            
            ScrollView(.horizontal) {
                LazyHStack(spacing: 15) {
                    ForEach(items, id: \.id) { item in
                        content(item)
                    }
                }
            }
        }
        .padding(.vertical, 10)
    }
}
