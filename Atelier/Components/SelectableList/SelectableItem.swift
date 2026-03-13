//
//  SelectableItem.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 13/03/26.
//

protocol SelectableItem: CaseIterable, Hashable, Identifiable {
    associatedtype CategoryType: Identifiable & CaseIterable & RawRepresentable where CategoryType.RawValue == String
    
    var id      : String       { get }
    var title   : String       { get }
    var category: CategoryType { get }
    var iconName: String?      { get }
}
