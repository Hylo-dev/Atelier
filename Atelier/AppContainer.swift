//
//  AppContainer.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 07/04/2026.
//


import SwiftData
import SwiftUI

@Observable
final class AppContainer {
    let applianceManager: ApplianceManager
    let garmentManager: GarmentManager
    let outfitManager: OutfitManager
    let captureManager: CaptureManager
    let laundryActivity: LaundryActivityManager
    let modelContainer: ModelContainer

    init() {
        
        let schema = Schema(versionedSchema: AtelierSchemaV1.self)
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            let container = try ModelContainer(for: schema, migrationPlan: AtelierMigrationPlan.self, configurations: [config])
            self.modelContainer = container
            
            let context = container.mainContext
            self.applianceManager = ApplianceManager(context)
            self.garmentManager = GarmentManager(context)
            self.outfitManager = OutfitManager(context)
            self.laundryActivity = LaundryActivityManager()
            self.captureManager = CaptureManager()
            
        } catch {
            fatalError("Errore Database: \(error.localizedDescription)")
        }
    }
    
    func setupServices(appDelegate: AppDelegate) {
        appDelegate.washingSessionManager = applianceManager
        appDelegate.laundryActivity = laundryActivity
        
        appDelegate.requestNotificationPermissions()
        laundryActivity.setupNotifications()
    }
}
