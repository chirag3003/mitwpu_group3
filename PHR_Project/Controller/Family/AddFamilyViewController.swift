//
//  AddFamilyController.swift
//  PHR_Project
//
//  Created by SDC_USER on 25/11/25.
//

import UIKit

class AddFamilyViewController: UIViewController, UITableViewDataSource,
    UITableViewDelegate
{
    @IBOutlet weak var tableView: UITableView!
    
    private var contacts: [Contact] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view.
        
        contacts = getAllData().family.contacts
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)
        -> Int
    {
        return contacts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "contact_cell",
            for: indexPath
        ) as! ContactTableViewCell
                 let contact = contacts[indexPath.row]
        cell.configure(with: contact)
        return cell
    }

}
