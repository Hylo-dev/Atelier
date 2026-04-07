//
//  FilterProtocol.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 07/04/2026.
//

import SwiftData


protocol FilterProtocol<T>: Equatable, Sendable {
    associatedtype T: PersistentModel
    var isFiltering: Bool { get }
    
    mutating func reset()
    func filter(_ items: [T]) -> [T]
}
