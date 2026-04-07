//
//  Repository.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 07/04/2026.
//


import SwiftData
import UIKit

protocol RepositoryProtocol<T, M> {
    associatedtype T: PersistentModel
    associatedtype M: Manager where M.T == T
        
    func create(item: T, image: UIImage?, manager: M) throws
    func update(item: T, image: UIImage?, manager: M) throws
    
}
