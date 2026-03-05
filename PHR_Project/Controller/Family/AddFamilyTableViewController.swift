//
//  AddFamilyTableViewController.swift
//  PHR_Project
//
//  Created by SDC_USER on 04/03/26.
//

import UIKit

class AddFamilyTableViewController: UITableViewController {

    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    @IBOutlet weak var familyNameTextfield: UITextField!
    @IBOutlet weak var tickButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure half-screen modal
        if let sheet = sheetPresentationController {
            sheet.detents = [.medium()]          // Only half screen
            sheet.prefersGrabberVisible = true   // Shows the drag handle at top
            sheet.preferredCornerRadius = 20
            sheet.detents = [.medium(), .large()]
        }
    }

    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func tickButtonTapped(_ sender: Any) {
        guard let name = familyNameTextfield.text?.trimmingCharacters(in: .whitespacesAndNewlines),
            !name.isEmpty
        else {
            showErrorAlert(message: "Please enter a family name.")
            return
        }

        FamilyService.shared.createFamily(name: name) { [weak self] result in
            switch result {
            case .success:
                self?.dismiss(animated: true)
            case .failure(let error):
                self?.showErrorAlert(message: error.localizedDescription)
            }
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

    private func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }



}
