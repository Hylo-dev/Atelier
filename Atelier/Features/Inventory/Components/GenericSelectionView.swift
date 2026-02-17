//
//  LaundrySymbolSelectionView.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 17/02/26.
//

import SwiftUI

protocol SelectableItem: CaseIterable, Hashable, Identifiable {
    associatedtype CategoryType: Identifiable & CaseIterable & RawRepresentable where CategoryType.RawValue == String
    
    var id      : String       { get }
    var title   : String       { get }
    var category: CategoryType { get }
    var iconName: String?      { get }
}

struct GenericSelectionView<Item: SelectableItem>: View {
    @Binding var selection: Set<Item>
    
    let columns = [GridItem(.adaptive(minimum: 80, maximum: 100))]
    
    var body: some View {
        List {

            ForEach(Array(Item.CategoryType.allCases), id: \.id) { category in
                Section(header: Text(category.rawValue)) {
                    LazyVGrid(columns: columns, spacing: 20) {

                        ForEach(Item.allCases.filter { $0.category == category }, id: \.id) { item in
                            VStack {
                                selectionCell(for: item)
                                
                            }
                            .onTapGesture {
                                toggleSelection(item)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
        }
        .navigationTitle("Select Options")
    }
    
    @ViewBuilder
    private func selectionCell(for item: Item) -> some View {
        let isSelected = selection.contains(item)
        
        VStack {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? Color.accentColor.opacity(0.15) : Color(uiColor: .secondarySystemFill))
                    .frame(height: 60)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
                    )
                
                if let icon = item.iconName {
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
                .font(.caption)
                .fontWeight(isSelected ? .medium : .regular)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .foregroundStyle(isSelected ? .primary : .secondary)
                .frame(minHeight: 30, alignment: .top)
        }
    }
    
    private func toggleSelection(_ item: Item) {
        withAnimation(.easeInOut(duration: 0.1)) {
            if self.selection.contains(item) {
                self.selection.remove(item)
                
            } else {
                self.selection.insert(item)
            }
        }
    }
}
