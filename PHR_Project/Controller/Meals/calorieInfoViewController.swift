//
//  calorieInfoViewController.swift
//  PHR_Project
//
//  Created by Sushant Pulipati on 12/12/25.
//

import UIKit

class calorieInfoViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func dismiss(_ sender: Any) {
        let confirmAlert = UIAlertController(
            title: "Are you sure?",
            message: "Do you feel like you have gained enough information about the knowledge you were seeking?",
            preferredStyle: .alert
        )
        
        // YES → show compliment alert, then dismiss
        confirmAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { [weak self] _ in
            
            // Second alert
            let wowAlert = UIAlertController(
                title: nil,
                message: "Wow you must be smart!",
                preferredStyle: .alert
            )
            
            // Present second alert
            self?.present(wowAlert, animated: true)
            
            // Auto dismiss after 3 seconds, then close the VC
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                wowAlert.dismiss(animated: true) {
                    self?.dismiss(animated: true)
                }
            }
        }))
        
        // NO → do nothing
        confirmAlert.addAction(UIAlertAction(title: "No", style: .cancel))
        
        present(confirmAlert, animated: true)
    }

    
}
