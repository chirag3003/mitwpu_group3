//
//  AddDetailsTableViewController.swift
//  PHR_Project
//
//  Created by SDC-USER on 24/01/26.
//

import UIKit

class AddDetailsTableViewController: UITableViewController {
    
    
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var firstName: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

       
    }
    

    @IBAction func doneButton(_ sender: Any) {
        
        guard let name = firstName.text, !name.isEmpty else {
            self.showAlert(
                title: "Missing info",
                message: "Please enter first name"
            )
            return
        }
        
        guard let name2 = lastName.text, !name2.isEmpty else {
            self.showAlert(
                title: "Missing info",
                message: "Please enter last name"
            )
            return
        }
        
        
        view.endEditing(true)
        dismiss(animated: true)
    }
    @IBAction func closeButton(_ sender: Any) {
        dismiss(animated: true)
    }
}
