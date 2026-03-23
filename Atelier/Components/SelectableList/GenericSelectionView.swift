//
//  GenericSelectionView.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 13/03/26.
//

import SwiftUI

struct GenericSelectionView<Item: SelectableItem>: View {
    
    @Binding
    var selection: Set<Item>
    
    let useSystemIcon: Bool
    
    private let columns = [
        GridItem(.adaptive(
            minimum: 80,
            maximum: 100
        ))
    ]
    
    init(
        selection    : Binding<Set<Item>>,
        useSystemIcon: Bool = false
    ) {
        self._selection    = selection
        self.useSystemIcon = useSystemIcon
    }
    
    var body: some View {
        List {
            ForEach(Array(Item.CategoryType.allCases), id: \.id) { category in
                Section(header: Text(category.rawValue.capitalized)) {
                    LazyVGrid(columns: columns, spacing: 16) {

                        ForEach(Item.allCases.filter { $0.category == category }, id: \.id) { item in
                            
                            selectionCell(for: item)
                                .onTapGesture {
                                    self.toggleSelection(item)
                                }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .sensoryFeedback(.selection, trigger: self.selection)
        .navigationTitle("Select Options")
    }
    
    @ViewBuilder
    private func selectionCell(for item: Item) -> some View {
        let isSelected = self.selection.contains(item)
        
        VStack {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.accentColor.opacity(0.15) : Color(uiColor: .secondarySystemFill))
                    .frame(height: 60)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
                    )
                
                if useSystemIcon, let icon = item.iconName {
                    Image(systemName: icon)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 30)
                        .foregroundColor(isSelected ? .accentColor : .primary)
                    
                } else if !useSystemIcon, let icon = item.iconName {
                    Image(icon)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 30)
                        .foregroundColor(isSelected ? .accentColor : .primary)
                    
                } else {
                    Text(String(item.title.prefix(2)).uppercased())
                        .font(.title2)
                        .fontWeight(.black)
                        .foregroundStyle(isSelected ? Color.accentColor : .gray.opacity(0.5))
                    
                }
            }
            
            Text(item.title)
                .font(.footnote)
                .fontWeight(isSelected ? .medium : .regular)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .foregroundStyle(isSelected ? .primary : .secondary)
                .frame(minHeight: 30, alignment: .top)
        }
    }
    
    
    private func toggleSelection(_ item: Item) {
        withAnimation(.easeInOut(duration: 0.1)) {
            if selection.contains(item) {
                selection.remove(item)
                
            } else {
                selection.insert(item)
            }
        }
    }
}
