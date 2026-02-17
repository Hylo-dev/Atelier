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
    // Create local DB
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Garment.self,
            Outfit.self
        ])
        
        let modelConfiguration = ModelConfiguration(
            schema              : schema,
            isStoredInMemoryOnly: false
        )

        do {
            return try ModelContainer(
                for           : schema,
                configurations: [modelConfiguration]
            )
            
        } catch {
            fatalError("Could not create ModelContainer Database: \(error)")
        }
        
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
