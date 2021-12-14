//
//  AppDelegate.swift
//  BackstageISS
//
//  Created by Donald Angelillo on 12/13/21.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.window = UIWindow()
        self.window?.makeKeyAndVisible()
        self.window?.rootViewController = MainViewController()
        return true
    }
}

