//
//  BrowseTableViewController.swift
//  PHR_Project
//
//  Created by SDC_USER on 08/12/25.
//

import UIKit

class BrowseTableViewController: UITableViewController {

    struct Category {
            let name: String
            let icon: String
            let color: UIColor
        }

        // 2. Data Source
        let categories: [Category] = [
            Category(name: "Activity", icon: "flame.fill", color: .systemOrange),
            Category(name: "Glucose", icon: "heart.fill", color: .systemRed),
            Category(name: "Water Intake", icon: "drop.fill", color: .systemBlue),
            Category(name: "Medications", icon: "pills.fill", color: .systemCyan),
            Category(name: "Allergy", icon: "allergens.fill", color: .systemTeal),
            Category(name: "Nutrition", icon: "fork.knife.circle", color: .systemGreen),
            Category(name: "Generate Summary", icon: "list.bullet.clipboard.fill", color: .systemPurple),
            Category(name: "Notifications", icon: "lightbulb.max.fill", color: .systemBlue),
            Category(name: "Symptoms", icon: "waveform.path.ecg", color: .systemYellow),
        ]

        override func viewDidLoad() {
            super.viewDidLoad()
            // Optional: Make the search bar background transparent if needed
            // navigationItem.hidesSearchBarWhenScrolling = false
        }

        // MARK: - Table view data source

        override func numberOfSections(in tableView: UITableView) -> Int {
            return 1
        }
        
        
       

        override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return categories.count
        }

        override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "browse_cell", for: indexPath)
            let item = categories[indexPath.row]
            
            // Modern Cell Configuration
            var content = cell.defaultContentConfiguration()
            
            // Text
            content.text = item.name
            content.textProperties.font = .systemFont(ofSize: 17, weight: .semibold)
            
            // Image
            content.image = UIImage(systemName: item.icon)
            content.imageProperties.tintColor = item.color
            
            cell.contentConfiguration = content
            return cell
        }
    }
