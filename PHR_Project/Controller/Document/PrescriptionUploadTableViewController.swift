//
//  PrescriptionUploadTableViewController.swift
//  PHR_Project
//
//  Created by Sushant Pulipati on 27/01/26.
//

import UIKit

class PrescriptionUploadTableViewController: UITableViewController {
    
    var selectedDoctor: DocDoctor?
    var doctorName: String?
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let doctor = selectedDoctor {
            self.title = doctor.name
            self.navigationItem.title = doctor.name
            doctorName = doctor.name
        } else if let name = doctorName {
            self.title = name
            self.navigationItem.title = name
        }

     
    }

    @IBAction func closeButton(_ sender: Any) {
        dismiss(animated: true)
    }
}
