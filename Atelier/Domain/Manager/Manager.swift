//
//  Manager.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 11/03/26.
//

import SwiftData

protocol Manager {
    associatedtype T: PersistentModel
    
    
    
    init(_ context: ModelContext)
    
    
    
    func insert(_ element: T)
    
    
    
    func update()
    
    
    
    func delete(_ element: T)
    
    
    
    func save()
}
