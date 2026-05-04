//
//  HorizontalScrollList.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 08/04/2026.
//

import SwiftUI
import SwiftData

struct HorizontalScrollList<T: PersistentModel, Content: View>: View {
    let items: [T]
    
    @ViewBuilder
    var content: (T) -> Content
    
    init(
        items               : [T],
        @ViewBuilder content: @escaping (T) -> Content
    ) {
        self.items               = items
        self.content             = content
    }
    
    var body: some View {
        
        ScrollView(.horizontal) {
            LazyHStack(spacing: 15) {
                ForEach(items, id: \.id) { item in
                    content(item)
                }
            }
        }
    }
}
