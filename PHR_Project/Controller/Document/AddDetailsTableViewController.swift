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
    var familyMember: FamilyMember?
    var canEditSharedData = false
    
    @IBAction func doneButton(_ sender: Any) {
        if familyMember != nil && !canEditSharedData {
            dismiss(animated: true)
            return
        }
        
        guard let firstName = firstName.text, !firstName.isEmpty else {
            self.showAlert(
                title: "Missing info",
                message: "Please enter first name"
            )
            return
        }
        
        guard let lastName = lastName.text, !lastName.isEmpty else {
            self.showAlert(
                title: "Missing info",
                message: "Please enter last name"
            )
            return
        }
        
        // Combine first and last name for doctor's full name
        let fullName = "Dr. \(firstName) \(lastName)"
        
        if let member = familyMember {
            SharedDataService.shared.createDocDoctor(
                for: member.userId,
                name: fullName
            ) { [weak self] result in
                switch result {
                case .success:
                    self?.dismiss(animated: true)
                case .failure(let error):
                    self?.showAlert(
                        title: "Error",
                        message:
                            "Failed to add doctor: \(error.localizedDescription)"
                    )
                }
            }
            return
        }

        // Create doctor via API (global list)
        DocDoctorService.shared.createDoctor(name: fullName)
        
        view.endEditing(true)
        dismiss(animated: true)
    }
    @IBAction func closeButton(_ sender: Any) {
        dismiss(animated: true)
    }
}
