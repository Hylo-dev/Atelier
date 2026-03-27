//
//  AtelierSchemaV2.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 26/03/2026.
//

import SwiftData


enum AtelierSchemaV2: VersionedSchema {
    static let versionIdentifier = Schema.Version(2, 0, 0)
    static let models: [any PersistentModel.Type] = [LaundrySession.self, Garment.self, Outfit.self]
}

enum AtelierMigrationPlan: SchemaMigrationPlan {
    static let schemas: [any VersionedSchema.Type] = [AtelierSchemaV1.self, AtelierSchemaV2.self]
    static let stages: [MigrationStage] = [.lightweight(fromVersion: AtelierSchemaV1.self, toVersion: AtelierSchemaV2.self)]
}
