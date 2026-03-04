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
                // Add your logout routing or logic here
                // e.g., self?.performSegue(withIdentifier: "LogoutSegue", sender: nil)
            }

            let menu = UIMenu(
                title: "Used a wrong number?",
                children: [logoutAction]
            )

            infoButton.menu = menu
        }
    }
