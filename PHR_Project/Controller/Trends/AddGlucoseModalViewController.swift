//
//  AddGlucoseModalViewController.swift
//  PHR_Project
//
//  Created by Sushant Pulipati on 10/12/25.
//

import UIKit

class AddGlucoseModalViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // If needed, additional setup can go here.
    }

    // MARK: - Actions
    @IBAction func doneModalButton(_ sender: Any) {
        dismiss(animated: true)
    }

    @IBAction func closeModalButton(_ sender: Any) {
        dismiss(animated: true)
    }
}
