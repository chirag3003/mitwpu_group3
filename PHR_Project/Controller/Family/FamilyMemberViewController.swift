//
//  FamilyMemberViewController.swift
//  PHR_Project
//
//  Created by SDC_USER on 25/11/25.
//

import UIKit

class FamilyMemberViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var pfpImage: UIImageView!
    // Selected member passed from FamilyViewController
    @IBOutlet weak var nameLabel: UILabel!
    var familyMember: FamilyMember?

    @IBOutlet weak var tableView: UITableView!
    
    // Data Models
    let accessOptions = ["Documents", "Meal Logs", "Symptom Logs", "Glucose"]
    let sharedOptions = ["Documents", "Meal Logs", "Symptom Logs", "Glucose"]
    let sharedOptionsSegue = ["familyDocumentsSegue" , "familyMealsSegue", "familySymptomsSegue", "familyGlucoseSegue"]

    override func viewDidLoad() {
        super.viewDidLoad()

        
        

        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        
        // Set member details
        nameLabel.text = familyMember?.name ?? "Family Member"
        
        //UI Changes
        pfpImage.addFullRoundedCorner()
        
    }

    // MARK: - Table View Data Source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2 // Section 0: Allow Access To, Section 1: Shared With You
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return accessOptions.count
        } else {
            return sharedOptions.count
        }
    }

    // MARK: - Section Headers

    // 1. Create a custom view for the Section Header
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        // Create a container view
        let headerView = UIView()
        headerView.backgroundColor = .clear // Keep transparent for Inset Grouped look
        
        // Create the Label
        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold) // Match your design
        titleLabel.textColor = .label // Black/White
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Set text based on section
        if section == 0 {
            titleLabel.text = "Allow Access To"
        } else {
            titleLabel.text = "Shared With You"
        }
        
        headerView.addSubview(titleLabel)
        
        // Set Constraints to create the SPACING
        NSLayoutConstraint.activate([
            // Left margin (matches Inset Grouped look)
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            
            // Top margin (Push text down a bit)
            titleLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 18),
            
            // BOTTOM MARGIN (This is the space between Text and Cells)
            // A larger negative number = more space
            titleLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -16)
        ])
        
        return headerView
    }

    // 2. Tell the table how tall this new custom header is
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50 // Adjust this if you want even more total space
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
            header.textLabel?.textColor = .label
        }
    }

    // MARK: - Cell Configuration

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "switch_cell", for: indexPath) as! MemberSwitchTableViewCell
            cell.titleLabel.text = accessOptions[indexPath.row]
            cell.permissionSwitch.isOn = true // TODO: Bind to real data
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "arrow_cell", for: indexPath)
            cell.textLabel?.text = sharedOptions[indexPath.row]
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 1 {
            print("Tapped on \(sharedOptions[indexPath.row])")
            // Navigate to details controller here
            performSegue(withIdentifier: sharedOptionsSegue[indexPath.row], sender: nil)
        }
    }
}
