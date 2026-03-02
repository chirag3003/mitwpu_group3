//
//  SceneDelegate.swift
//  PHR_Project
//
//  Created by SDC-USER on 29/09/25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        if AuthService.shared.isLoggedIn {
            if CoreDataManager.shared.fetchUserProfile() != nil {
                // Authenticated + has profile → main app
                let mainTabBar = storyboard.instantiateViewController(withIdentifier: "mainTabBarController")
                window.rootViewController = mainTabBar
            } else {
                // Authenticated but no profile → show onboarding welcome screen
                let welcomeVC = storyboard.instantiateViewController(withIdentifier: "onboardingWelcomeScreen")
                let navController = UINavigationController(rootViewController: welcomeVC)
                window.rootViewController = navController
            }
        } else {
            // Not authenticated — show onboarding / login flow
            let onboarding = storyboard.instantiateViewController(withIdentifier: "onboardingNavController")
            window.rootViewController = onboarding
        }

        self.window = window
        window.makeKeyAndVisible()
    }

    /// Replaces the root view controller with the main tab bar (called after login + profile check)
    static func switchToMainApp() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainTabBar = storyboard.instantiateViewController(withIdentifier: "mainTabBarController")

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }

        UIView.transition(with: window, duration: 0.4, options: .transitionCrossDissolve) {
            window.rootViewController = mainTabBar
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


}

