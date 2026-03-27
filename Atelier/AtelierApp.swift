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
    
    let applianceManager    : ApplianceManager
    let garmentManager      : GarmentManager
    let outfitManager       : OutfitManager
    let captureManager      : CaptureManager
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
                migrationPlan: AtelierMigrationPlan.self,
                configurations: [modelConfiguration]
            )
            
            applianceManager = ApplianceManager(sharedModelContainer.mainContext)
            garmentManager   = GarmentManager(sharedModelContainer.mainContext)
            outfitManager    = OutfitManager(sharedModelContainer.mainContext)
            
            captureManager = CaptureManager()
            
            appDelegate.applianceManager = applianceManager
            
            
        } catch {
            print("Could not create ModelContainer Database: \(error.localizedDescription)")
            fatalError("Exit")
        }
        
        
        appDelegate.requestNotificationPermissions()
        LaundryActivityManager.shared.setupNotifications()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(applianceManager)
                .environment(garmentManager)
                .environment(outfitManager)
                .environment(captureManager)
        }
        .modelContainer(sharedModelContainer)
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    var applianceManager: ApplianceManager?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    
    func userNotificationCenter(
        _          center  : UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        let userInfo = response.notification.request.content.userInfo
        
        let isFinishAction = response.actionIdentifier == "FINISH_ACTION"
        let isDefaultTap   = response.actionIdentifier == UNNotificationDefaultActionIdentifier
        
        if (isFinishAction || isDefaultTap),
           let sessionIdString = userInfo["SESSION_ID"] as? String {
                        
            await MainActor.run {
                
                if let context = applianceManager?.context,
                   let sessionId = UUID(uuidString: sessionIdString) {
                    
                    let descriptor = FetchDescriptor<LaundrySession>(
                        predicate: #Predicate { $0.id == sessionId }
                    )
                    
                    if let session = try? context.fetch(descriptor).first {
                        applianceManager?.finishWashing(session)
                        print("Session complete!")
                        
                    } else {
                        print("Session not found on DB")
                    }
                }
            }
            
            LaundryActivityManager.shared.stop()
        }
    }
    
    func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .badge, .sound]
        ) { granted, error in
            
            if granted {
                print("Check notification")
                
            } else if let error = error {
                print("Error notification: \(error.localizedDescription)")
            }
        }
    }
}
