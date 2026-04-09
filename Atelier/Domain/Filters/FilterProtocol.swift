//
//  FilterProtocol.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 07/04/2026.
//

import SwiftData
import Foundation

protocol FilterProtocol<T>: Equatable, AnyObject {
    associatedtype T: PersistentModel
    
    var isFiltering: Bool { get }
    
    func reset()
    func generatePredicate() -> Predicate<T>
    
    init()
}
