//
//  AtelierApp.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 15/02/26.
//

import SwiftUI
import SwiftData

@main
struct AtelierApp: App {
    
    let applianceManager    : ApplianceManager
    let sharedModelContainer: ModelContainer
    
    init() {
        
        let schema = Schema(versionedSchema: AtelierSchemaV1.self)
        
        let modelConfiguration = ModelConfiguration(
            schema              : schema,
            isStoredInMemoryOnly: false
        )
        
        do {
            sharedModelContainer = try ModelContainer(
                for           : schema,
                configurations: [modelConfiguration]
            )
            
            applianceManager = ApplianceManager(sharedModelContainer.mainContext)
            
        } catch {
            print("Could not create ModelContainer Database: \(error.localizedDescription)")
            fatalError("Exit")
        }
        
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(applianceManager)
        }
        .modelContainer(sharedModelContainer)
    }
}
