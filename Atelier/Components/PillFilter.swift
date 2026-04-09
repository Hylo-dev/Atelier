//
//  PillFilter.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 09/04/2026.
//

import SwiftUI

struct PillFilter<T: RawRepresentable & Hashable & Identifiable>: Equatable, View where T.RawValue == String {
        
    let item: T
    
    @Binding
    var selection: Set<T>?
    
    static func == (lhs: PillFilter<T>, rhs: PillFilter<T>) -> Bool {
        lhs.item == rhs.item &&
        lhs.selection == rhs.selection
    }
    
    var body: some View {
        let isSelected = selection?.contains(item) ?? false
        
        Text(item.rawValue.capitalized)
            .font(.system(size: 14, weight: .medium))
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                isSelected ? Color.accentColor : Color(.tertiarySystemFill)
            )
            .foregroundStyle(isSelected ? .white : .primary)
            .clipShape(Capsule())
            .onTapGesture {
                var currentSet = selection ?? []
                
                if currentSet.contains(item) {
                    currentSet.remove(item)
                } else {
                    currentSet.insert(item)
                }
                
                withAnimation {
                    selection = currentSet.isEmpty ? nil : currentSet
                }
            }
    }
}
