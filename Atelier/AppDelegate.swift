//
//  AppDelegate.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 07/04/2026.
//

import UIKit


class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    var washingSessionManager: WashingSessionManaging?
    var laundryActivity      : LaundryActivityProviding?
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
        
    ) -> Bool {
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
                
                if let sessionId = UUID(uuidString: sessionIdString) {
                    
                    do {
                        try washingSessionManager?
                            .finishWashingSession(id: sessionId)
                        
                    } catch {
                        print(error.localizedDescription) // TODO: Manage error
                    }
                }
            }
            
            laundryActivity?.stop()
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
