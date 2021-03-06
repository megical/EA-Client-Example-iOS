//
//  AppDelegate.swift
//  EA Client Example
//
//  Created by Antti Köliö on 25.3.2021.
//

import UIKit
import MegicalEasyAccess_SDK_iOS
import SwiftyBeaver

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        EALog.config() // default logging conf, you can do this yourself also
        // like so:
//        let log = SwiftyBeaver.self
//        let console = ConsoleDestination()
//        console.minLevel = .debug
//        log.addDestination(console)
        
        let eaOauthRedirectRegistered = URLProtocol.registerClass(ExampleEARedirectURLProtocol.self)
        print("eaOauthRedirectRegistered: \(eaOauthRedirectRegistered)")
        
        return true
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

