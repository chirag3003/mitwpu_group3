//
//  ProfileTableViewController.swift
//  PHR_Project
//
//  Created by SDC_USER on 26/11/25.
//

import UIKit

class ProfileTableViewController: UITableViewController {

    
    @IBOutlet weak var profileImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        profileImage.addFullRoundedCorner()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }

    @IBAction func onDoneClick(_ sender: Any) {
        self.dismiss(animated: true)
    }
    

        
    

}
