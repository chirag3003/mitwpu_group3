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
    private var families: [Family] = []

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

        FamilyService.shared.fetchFamilies { [weak self] _ in
            guard let self = self else { return }
            self.families = FamilyService.shared.getFamilies()
            self.tableView.reloadData()
        }
    }

    // MARK: - Actions
    
    @IBAction func closeButtontapped(_ sender: Any) {
        dismiss(animated: true)
    }
    
    // MARK: - Table View Data Source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return families.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Make sure your prototype cell in the storyboard has the identifier "FamilyCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: "family_cell", for: indexPath)
        
        // Configure the cell text
        cell.textLabel?.text = families[indexPath.row].name
        
        // Adds the little '>' arrow on the right
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }

    // MARK: - Table View Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Deselect the row so it doesn't stay gray
        tableView.deselectRow(at: indexPath, animated: true)
        let family = families[indexPath.row]
        FamilyService.shared.setCurrentFamily(id: family.apiID)
        dismiss(animated: true)
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
                    
                    let family = self.families[indexPath.row]
                    if let familyId = family.apiID {
                        FamilyService.shared.leaveFamily(familyId: familyId) { success in
                            guard success else { return }
                            self.families = FamilyService.shared.getFamilies()
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        }
                    }
                }
                
                // Return the menu containing our action
                return UIMenu(title: "", children: [exitAction])
            }
        }
}
