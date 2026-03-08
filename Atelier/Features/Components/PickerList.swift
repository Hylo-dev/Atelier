//
//  PickerList.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 08/03/26.
//

import SwiftUI

struct PickerList<T: Hashable, Content: View>: View {
    
    let title: LocalizedStringKey
    
    @Binding
    var selection: T
    
    let content: Content
    
    init(
        _ title  : LocalizedStringKey,
        selection: Binding<T>,
        @ViewBuilder content: () -> Content
    ) {
        self.title      = title
        self._selection = selection
        self.content    = content()
    }
    
    var body: some View {
        
        HStack {
            Text(self.title)
            
            Spacer()
            
            Picker(self.title, selection: self.$selection) {
                self.content
            }
            .tint(.secondary)
            .pickerStyle(.menu)
        }
    }
}
