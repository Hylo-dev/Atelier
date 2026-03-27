//
//  AtelierSchema.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 11/03/26.
//

import SwiftData
import Foundation

enum AtelierSchemaV1: VersionedSchema {
    static let versionIdentifier = Schema.Version(1, 0, 0)
    
    
    
    static var models: [any PersistentModel.Type] {
        [Garment.self, Outfit.self, LaundrySession.self]
    }
    
    
    // Models class added with extensions
}
