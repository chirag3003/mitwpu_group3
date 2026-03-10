//
//  WelcomeViewController.swift
//  PHR_Project
//
//  Created by SDC_USER on 04/03/26.
//

import UIKit

class WelcomeViewController: UIViewController {
    
    @IBOutlet weak var infoButton: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupInfoMenu()
        // Do any additional setup after loading the view.
    }
    
    private func setupInfoMenu() {
            let logoutAction = UIAction(
                title: "Logout",
                image: UIImage(systemName: "rectangle.portrait.and.arrow.right"),
                attributes: .destructive
            ) { [weak self] _ in
                self?.handleLogout()
            }

            let menu = UIMenu(
                title: "Used a wrong number?",
                children: [logoutAction]
            )

            infoButton.menu = menu
        }
    
    private func handleLogout() {
        AuthService.shared.logout()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let onboarding = storyboard.instantiateViewController(
            withIdentifier: "onboardingNavController"
        )
        resetRootViewController(to: onboarding)
    }
    
    private func resetRootViewController(to rootViewController: UIViewController) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first
        else { return }
        UIView.transition(
            with: window,
            duration: 0.4,
            options: .transitionCrossDissolve
        ) {
            window.rootViewController = rootViewController
        }
    }
    }
