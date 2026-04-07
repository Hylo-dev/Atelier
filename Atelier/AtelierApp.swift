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
    
    @UIApplicationDelegateAdaptor(AppDelegate.self)
    var appDelegate
    
    @State
    private var container = AppContainer()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(container.applianceManager)
                .environment(container.garmentManager)
                .environment(container.outfitManager)
                .environment(container.captureManager)
                .task {
                    container.setupServices(appDelegate: appDelegate)
                }
        }
        .modelContainer(container.modelContainer)
    }
}
