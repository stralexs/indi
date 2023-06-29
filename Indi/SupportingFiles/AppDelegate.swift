//
//  AppDelegate.swift
//  Indi
//
//  Created by Alexander Sivko on 29.04.23.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let userNotificationCenter = LocalNotificationsManager()
        userNotificationCenter.sendNotification()
        return true
    }

    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {}
}

extension AppDelegate: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController is NewKitSelectionViewController {
            if let newKitSelectionVC = tabBarController.storyboard?.instantiateViewController(withIdentifier: "NewKitSelectionVC") {
                newKitSelectionVC.modalPresentationStyle = .overCurrentContext
                tabBarController.present(newKitSelectionVC, animated: true)
                return false
            }
        }

        return true
    }
}

