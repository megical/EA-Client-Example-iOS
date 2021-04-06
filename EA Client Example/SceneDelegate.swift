//
//  SceneDelegate.swift
//  EA Client Example
//
//  Created by Antti Köliö on 25.3.2021.
//

import UIKit
import SwiftyBeaver

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
        
        // Determine who sent the URL.
        // Called if app is not in memory
        if let urlContext = connectionOptions.urlContexts.first {
            SwiftyBeaver.debug("scene willConnectTo session")
            let sendingAppID = urlContext.options.sourceApplication
            let url = urlContext.url
            SwiftyBeaver.info("source application = \(sendingAppID ?? "Unknown")")
            SwiftyBeaver.debug("url = \(url)")
            
            _ = self.handleEaCallback(url: url)
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        // Determine who sent the URL.
        if let urlContext = URLContexts.first {
            SwiftyBeaver.debug("scene opening url")
            let sendingAppID = urlContext.options.sourceApplication
            let url = urlContext.url
            SwiftyBeaver.info("source application = \(sendingAppID ?? "Unknown")")
            SwiftyBeaver.debug("url = \(url)")
                
            _ = self.handleEaCallback(url: url)
        }
    }
    
    func handleEaCallback(url: URL) -> Bool {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            return false
        }
        
        guard components.path.contains(eaCallbackPath) else {
            return false
        }
        
        SwiftyBeaver.info("\(eaCallbackPath) path called")
        
        if let loginCode = components.queryItems?.first(where: { $0.name == "loginCode" })?.value {
            if loginCode.count > 0 {
                SwiftyBeaver.debug("collected loginCode: \(loginCode) from url")
                NotificationCenter.default.post(name: .init(rawValue: NOTIFICATION_NAME_EASY_ACCESS_SUCCESS),
                                                object: loginCode)
                return true
            }
        }
        
        return false
    }

}

