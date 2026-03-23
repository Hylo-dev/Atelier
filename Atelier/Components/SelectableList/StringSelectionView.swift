//
//  LaundrySymbolSelectionView.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 17/02/26.
//

import SwiftUI


struct StringSelectionView: View {
    
    let title: String
    let items: [String]
    
    @Binding
    var selection: Set<String>
    
    private let columns = [
        GridItem(.adaptive(minimum: 80, maximum: 100))
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                
                ForEach(self.items, id: \.self) { item in
                    let isSelected = self.selection.contains(item)
                    
                    SelectableCell(
                        item      : item,
                        isSelected: isSelected,
                        action: {
                            self.toggleSelection(item)
                        }
                    )
                    .equatable()
                }
            }
            .padding(16)
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 26))
        }
        .padding()
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle(self.title)
    }
    
    private func toggleSelection(_ item: String) {
        withAnimation(.easeInOut(duration: 0.1)) {
            if self.selection.contains(item) {
                self.selection.remove(item)
                
            } else {
                self.selection.insert(item)
            }
        }
    }
}

fileprivate
struct SelectableCell: View, Equatable {
    
    let item      : String
    let isSelected: Bool
    let action    : () -> Void
    
    static func == (lhs: SelectableCell, rhs: SelectableCell) -> Bool {
        return lhs.item == rhs.item && lhs.isSelected == rhs.isSelected
    }
    
    var body: some View {
        Button(action: action) {
            VStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isSelected ? Color.accentColor.opacity(0.15) : Color(uiColor: .secondarySystemFill))
                        .frame(height: 60)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
                        )
                    
                    Text(String(item.prefix(2)).uppercased())
                        .font(.title2)
                        .fontWeight(.black)
                        .foregroundStyle(isSelected ? Color.accentColor : .gray.opacity(0.5))
                }
                
                Text(item)
                    .font(.caption)
                    .fontWeight(isSelected ? .medium : .regular)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .foregroundStyle(isSelected ? .primary : .secondary)
                    .frame(minHeight: 30, alignment: .top)
            }
        }
        .buttonStyle(.plain)
    }
}
