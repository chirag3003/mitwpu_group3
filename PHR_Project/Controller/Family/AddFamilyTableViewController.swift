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
        dismiss(animated: true)
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



}
