//
//  MultiPicker.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 16/02/26.
//

import SwiftUI

struct MultiPicker<
    SelectionValue,
    Content,
    Label
>: View where SelectionValue: Hashable & Identifiable, Content: View, Label: View {
    
    private var title    : String
    private var selection: Binding<Set<SelectionValue>>
    private var items    : [SelectionValue]
    private var content  : (SelectionValue) -> Content
    private var label    : Label

    init(
        _ title  : String,
        selection: Binding<Set<SelectionValue>>,
        items    : [SelectionValue],
        @ViewBuilder content: @escaping (SelectionValue) -> Content
        
    ) where Label == Text {
        self.title     = title
        self.label     = Text(title)
        self.selection = selection
        self.items     = items
        self.content   = content
    }

    init(
        selection: Binding<Set<SelectionValue>>,
        items: [SelectionValue],
        @ViewBuilder content: @escaping (SelectionValue) -> Content, @ViewBuilder label: () -> Label
    ) {
        self.title     = "Multi Picker"
        self.selection = selection
        self.items     = items
        self.content   = content
        self.label     = label()
    }

    var body: some View {
        NavigationLink {

            List {
                ForEach(self.items) { item in
                    Button(action: { self.toggleSelection(item) }) {
                        HStack {
                            self.content(item)
                            
                            Spacer()
                            
                            if self.selection.wrappedValue.contains(item) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                            }
                        }
                    }
                    .foregroundStyle(.primary)
                }
            }
            .navigationTitle(self.title)
            
        } label: {
            HStack {
                self.label
                
                Spacer()
                
                Text("\(selection.wrappedValue.count) selected")
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func toggleSelection(_ item: SelectionValue) {
        if self.selection.wrappedValue.contains(item) {
            self.selection.wrappedValue.remove(item)
            
        } else {
            self.selection.wrappedValue.insert(item)
        }
    }
}
