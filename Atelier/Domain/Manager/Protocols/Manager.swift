//
//  Manager.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 11/03/26.
//

import SwiftData

protocol Manager<T> {
    associatedtype T: PersistentModel
    
    func insert(_ element: T) throws
    
    func update() throws
    
    func delete(_ element: T) throws
}
