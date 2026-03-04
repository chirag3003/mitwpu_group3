//
//  FamilySwitchTableViewController.swift
//  PHR_Project
//
//  Created by SDC_USER on 04/03/26.
//

import UIKit

class FamilySwitchTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: - Outlets
    @IBOutlet var tableView: UITableView!
    // Replace this array type with your actual Family model if you have one
    private var familyNames: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        setupHalfModal()
    }
    
    private func setupHalfModal() {
            // Check if we are running on iOS 15+ and being presented as a sheet
            if let sheet = self.sheetPresentationController {
                // .medium() starts it at half screen, .large() lets the user drag it to full screen
                sheet.detents = [.medium(), .large()]
                
                // Shows the little grabber handle at the top
                sheet.prefersGrabberVisible = true
                
                sheet.preferredCornerRadius = 24
            }
        }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Fetch the latest families here so newly created ones appear instantly
        // Example: familyNames = FamilyService.shared.getAllFamilies()
        
        // For now, using your placeholder data:
        familyNames = ["Chavans", "The Bhalotias", "Saxena Babies"]
        
        tableView.reloadData()
    }

    // MARK: - Actions
    
    @IBAction func closeButtontapped(_ sender: Any) {
        dismiss(animated: true)
    }
    
    // MARK: - Table View Data Source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return familyNames.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Make sure your prototype cell in the storyboard has the identifier "FamilyCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: "family_cell", for: indexPath)
        
        // Configure the cell text
        cell.textLabel?.text = familyNames[indexPath.row]
        
        // Adds the little '>' arrow on the right
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }

    // MARK: - Table View Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Deselect the row so it doesn't stay gray
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Currently does nothing else, as requested for backend handling later
        print("Selected family: \(familyNames[indexPath.row])")
    }
    
    // MARK: - Context Menu (Long Press)
        
        func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
            
            return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
                
                // Create the Exit action
                let exitAction = UIAction(
                    title: "Exit Family",
                    image: UIImage(systemName: "rectangle.portrait.and.arrow.right"),
                    attributes: .destructive // Makes the text and icon red!
                ) { [weak self] _ in
                    
                    guard let self = self else { return }
                    
                    // Remove the family from your data array
                    let exitedFamily = self.familyNames.remove(at: indexPath.row)
                    print("Exited family: \(exitedFamily)")
                    
                    // Animate the row disappearing from the table view
                    DispatchQueue.main.async {
                        self.tableView.deleteRows(at: [indexPath], with: .fade)
                    }
                    
                    // (Future) Make your backend API call here to actually remove the user from the family in the database
                }
                
                // Return the menu containing our action
                return UIMenu(title: "", children: [exitAction])
            }
        }
}
