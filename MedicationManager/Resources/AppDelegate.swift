//
//  AppDelegate.swift
//  MedicatioManager
//
//  Created by Tanner Perry on 11/29/21.
//

import UIKit
import CoreData


@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { authorized, error in
            if let error = error {
                print("there was an error requesting permission to show local norifications: \(error)")
            }
            if authorized {
                UNUserNotificationCenter.current().delegate = self
                self.setNotificationCategories()
                print("✅ User granted authorization to show local notifications")
            } else {
                print("🛑 User denied aurhorization to show local notifications")
            }
        }
        
        return true
    }
    
    
    
    private func setNotificationCategories() {
        let markTakenAction = UNNotificationAction(identifier: Strings.markTakenActionIdentifier, title: Strings.markAsTakenButtonTitle, options: UNNotificationActionOptions(rawValue: 0))
        let ignoreAction = UNNotificationAction(identifier: Strings.ignoreActionIdentifier, title: Strings.ignoreActionButton, options: UNNotificationActionOptions(rawValue: 0))
        
        let category = UNNotificationCategory(identifier: Strings.notificationCategoryIdentifier,
                                              actions: [markTakenAction, ignoreAction],
                                              intentIdentifiers: [],
                                              hiddenPreviewsBodyPlaceholder: "",
                                              categorySummaryFormat: nil,
                                              options: .customDismissAction)
        
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Strings.medicationReminderReceived), object: nil)
        completionHandler([.sound, .badge, .banner])
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.actionIdentifier == Strings.markTakenActionIdentifier,
           let id = response.notification.request.content.userInfo[Strings.MedicationIDKey] as? String {
            MedicationController.shared.markMedicationTaken(withID: id)
            completionHandler()
        }
    }
}

