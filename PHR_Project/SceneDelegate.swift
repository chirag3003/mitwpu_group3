//
//  SceneDelegate.swift
//  PHR_Project
//
//  Created by SDC-USER on 29/09/25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        if AuthService.shared.isLoggedIn {
            if CoreDataManager.shared.fetchUserProfile() != nil {
                // Authenticated + has profile → main app
                let mainTabBar = storyboard.instantiateViewController(
                    withIdentifier: "mainTabBarController"
                )
                window.rootViewController = mainTabBar
            } else {
                // Authenticated but no profile → show onboarding welcome screen
                let welcomeVC = storyboard.instantiateViewController(
                    withIdentifier: "onboardingWelcomeScreen"
                )
                let navController = UINavigationController(
                    rootViewController: welcomeVC
                )
                window.rootViewController = navController
            }
        } else {
            // Not authenticated — show onboarding / login flow
            let onboarding = storyboard.instantiateViewController(
                withIdentifier: "onboardingNavController"
            )
            window.rootViewController = onboarding
        }

        self.window = window
        window.makeKeyAndVisible()

        // Handle cold start deep link
        if let urlContext = connectionOptions.urlContexts.first {
            let url = urlContext.url
            if url.scheme == "phr" {
                // Slight delay to ensure UI is ready
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.handleDeepLink(url)
                }
            }
        }
    }

    /// Replaces the root view controller with the main tab bar (called after login + profile check)
    static func switchToMainApp() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainTabBar = storyboard.instantiateViewController(
            withIdentifier: "mainTabBarController"
        )

        guard
            let windowScene = UIApplication.shared.connectedScenes.first
                as? UIWindowScene,
            let window = windowScene.windows.first
        else { return }

        UIView.transition(
            with: window,
            duration: 0.4,
            options: .transitionCrossDissolve
        ) {
            window.rootViewController = mainTabBar
        }
    }

    func scene(
        _ scene: UIScene,
        openURLContexts URLContexts: Set<UIOpenURLContext>
    ) {
        guard let url = URLContexts.first?.url else { return }
        print("Received Deep Link: \(url)")

        if url.scheme == "phr" {
            handleDeepLink(url)
        }
    }

    private func handleDeepLink(_ url: URL) {
        // Parse the URL
        guard
            let components = URLComponents(
                url: url,
                resolvingAgainstBaseURL: true
            ),
            let host = components.host
        else { return }

        switch host {
        case "add-meal":
            let openCamera =
                components.queryItems?.first(where: { $0.name == "camera" })?
                .value == "true"
            navigateToMeals(openCamera: openCamera)

        case "add-glucose":
            navigateToAddGlucose()

        default:
            break
        }
    }

    private func navigateToMeals(openCamera: Bool) {
        // Ensure UI operations are on main thread
        DispatchQueue.main.async {
            guard
                let windowScene = UIApplication.shared.connectedScenes.first
                    as? UIWindowScene,
                let window = windowScene.windows.first,
                let rootVC = window.rootViewController
            else {
                return
            }

            // If user is not logged in, we shouldn't navigate
            if !AuthService.shared.isLoggedIn {
                return
            }

            // 1. Switch to Main Tab (Home - Index 0)
            if let tabBarController = rootVC as? UITabBarController {
                tabBarController.selectedIndex = 0
            }

            // Function to present the Add Meal screen via Navigation Controller
            func presentAddMeal() {
                let storyboard = UIStoryboard(name: "Meals", bundle: nil)

                // Load the Navigation Controller, NOT the VC directly
                if let navVC = storyboard.instantiateViewController(
                    withIdentifier: "AddMealScreenNav"
                ) as? UINavigationController {

                    // Access the root VC to set delegate/launch camera if needed
                    if let addMealVC = navVC.topViewController
                        as? AddMealModalViewController
                    {

                        // Configure presentation style
                        if let sheet = navVC.sheetPresentationController {
                            sheet.detents = [.medium(), .large()]
                        } else {
                            navVC.modalPresentationStyle = .pageSheet
                        }

                        // Present from the top-most view controller (which should be the Tab Bar now)
                        var topController = window.rootViewController
                        while let presented = topController?
                            .presentedViewController
                        {
                            topController = presented
                        }

                        topController?.present(navVC, animated: true) {
                            if openCamera {
                                // Slight delay for smooth transition
                                DispatchQueue.main.asyncAfter(
                                    deadline: .now() + 0.5
                                ) {
                                    addMealVC.launchCamera()
                                }
                            }
                        }
                    }
                }
            }

            // Dismiss any existing modals first to avoid stacking issues
            if rootVC.presentedViewController != nil {
                rootVC.dismiss(animated: true) {
                    presentAddMeal()
                }
            } else {
                presentAddMeal()
            }
        }
    }

    private func navigateToAddGlucose() {
        DispatchQueue.main.async {
            guard
                let windowScene = UIApplication.shared.connectedScenes.first
                    as? UIWindowScene,
                let window = windowScene.windows.first,
                let rootVC = window.rootViewController
            else {
                return
            }

            if !AuthService.shared.isLoggedIn { return }

            // 1. Switch to Main Tab (Home - Index 0)
            if let tabBarController = rootVC as? UITabBarController {
                tabBarController.selectedIndex = 0
            }

            func presentGlucose() {
                // Ensure we use the capitalized storyboard name
                let storyboard = UIStoryboard(name: "Glucose", bundle: nil)

                print(
                    "DEBUG: Attempting to instantiate AddGlucoseScreen from Glucose.storyboard"
                )
                if let glucoseVC = storyboard.instantiateViewController(
                    withIdentifier: "AddGlucoseScreen"
                ) as? AddGlucoseModalViewController {
                    print(
                        "DEBUG: Successfully instantiated AddGlucoseModalViewController"
                    )

                    // Wrap in Navigation Controller for "Done/Cancel" buttons
                    let navVC = UINavigationController(
                        rootViewController: glucoseVC
                    )

                    if let sheet = navVC.sheetPresentationController {
                        sheet.detents = [.medium()]
                    } else {
                        navVC.modalPresentationStyle = .pageSheet
                    }

                    var topController = window.rootViewController
                    while let presented = topController?.presentedViewController
                    {
                        topController = presented
                    }

                    print(
                        "DEBUG: Presenting AddGlucoseScreen on \(String(describing: topController))"
                    )
                    topController?.present(navVC, animated: true)
                } else {
                    print(
                        "ERROR: Failed to instantiate AddGlucoseScreen as AddGlucoseModalViewController"
                    )
                }
            }

            if rootVC.presentedViewController != nil {
                rootVC.dismiss(animated: true) {
                    presentGlucose()
                }
            } else {
                presentGlucose()
            }
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
