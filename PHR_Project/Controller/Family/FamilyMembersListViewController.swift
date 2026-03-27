//
//  FamilyMembersListViewController.swift
//  PHR_Project
//
//  Created by SDC_USER on 27/03/26.
//

import UIKit

class FamilyMembersListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var family: Family?
        private var familyData: [FamilyMember] = []

        override func viewDidLoad() {
            super.viewDidLoad()
            view.backgroundColor = .systemGroupedBackground
            tableView.backgroundColor = .clear
            
            navigationItem.title = family?.name ?? "Family Members"
            
            setupTableView()
            fetchMembers()
        }
        
        private func setupTableView() {
            tableView.delegate = self
            tableView.dataSource = self
            
            // Gives the cells a larger size to perfectly fit the 60x60 profile images
            tableView.rowHeight = 85
            
            // Adds extra breathing room between the Navigation Bar and the first cell
            tableView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 20, right: 0)
        }

        private func fetchMembers() {
            guard let familyId = family?.apiID else { return }
            FamilyService.shared.fetchFamilyMembers(familyId: familyId) { [weak self] _ in
                guard let self = self else { return }
                self.familyData = FamilyService.shared.getMembersForCurrentFamily()
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }

        // MARK: - Table View Data Source
        
        // 1. Give every member their own section
        func numberOfSections(in tableView: UITableView) -> Int {
            return familyData.count
        }

        // 2. Only put ONE row inside each section
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return 1
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "familyMember_cell", for: indexPath)
            
            // 3. IMPORTANT: Grab the member using indexPath.section instead of indexPath.row
            let member = familyData[indexPath.section]

            var content = cell.defaultContentConfiguration()
            content.text = member.name
            content.textProperties.font = UIFont.systemFont(ofSize: 18, weight: .medium)

            // Placeholder image configuration
            let symbolConfig = UIImage.SymbolConfiguration(pointSize: 60)
            let placeholder = UIImage(systemName: "person.circle.fill", withConfiguration: symbolConfig)?.withTintColor(.systemGray3, renderingMode: .alwaysOriginal)
            content.image = placeholder

            content.imageProperties.maximumSize = CGSize(width: 60, height: 60)
            content.imageProperties.reservedLayoutSize = CGSize(width: 60, height: 60)
            content.imageProperties.cornerRadius = 30
            cell.contentConfiguration = content

            // Load profile image
            if !member.imageName.isEmpty, let url = URL(string: member.imageName) {
                URLSession.shared.dataTask(with: url) { data, response, error in
                    guard let data = data, error == nil, let loadedImage = UIImage(data: data) else { return }

                    DispatchQueue.main.async {
                        if tableView.indexPath(for: cell) == indexPath {
                            var updatedContent = cell.defaultContentConfiguration()
                            updatedContent.text = member.name
                            updatedContent.textProperties.font = UIFont.systemFont(ofSize: 18, weight: .medium)
                            updatedContent.image = loadedImage
                            
                            updatedContent.imageProperties.maximumSize = CGSize(width: 60, height: 60)
                            updatedContent.imageProperties.reservedLayoutSize = CGSize(width: 60, height: 60)
                            updatedContent.imageProperties.cornerRadius = 30
                            
                            cell.contentConfiguration = updatedContent
                        }
                    }
                }.resume()
            }

            cell.accessoryType = .disclosureIndicator
            return cell
        }
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            tableView.deselectRow(at: indexPath, animated: true)
            
            // 4. IMPORTANT: Grab the member using indexPath.section here as well!
            let selectedMember = familyData[indexPath.section]
            performSegue(withIdentifier: SegueIdentifiers.goToMemberDetails, sender: selectedMember)
        }
        
        // Optional: Adjust the height between the individual floating cells
        func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            return 8 // Space above each cell
        }
        
        func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
            return 8 // Space below each cell
        }
    
    // MARK: - Swipe Actions (Delete Member)
        
    // MARK: - Swipe Actions (Delete Member)
        
        func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
            // Optional: If you only want the Admin to be able to delete, you could check that here!
            return true
        }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            if editingStyle == .delete {
                let memberToDelete = familyData[indexPath.section]
                guard let familyId = family?.apiID else { return }
                
                // FIX: Use the exact property name from your FamilyMember struct
                let userIdToRemove = memberToDelete.userId
                
                // 1. Create the confirmation alert
                let alert = UIAlertController(
                    title: "Remove Member",
                    message: "Are you sure you want to remove \(memberToDelete.name) from the family?",
                    preferredStyle: .alert
                )
                
                // 2. Cancel Action (Swipes the cell back to normal)
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
                    tableView.reloadSections(IndexSet(integer: indexPath.section), with: .automatic)
                }
                
                // 3. Delete Action (Calls the backend)
                let deleteAction = UIAlertAction(title: "Remove", style: .destructive) { [weak self] _ in
                    guard let self = self else { return }
                    
                    FamilyService.shared.removeMember(familyId: familyId, userId: userIdToRemove) { result in
                        DispatchQueue.main.async {
                            switch result {
                            case .success(_):
                                // Successfully removed from backend, update UI
                                self.familyData.remove(at: indexPath.section)
                                self.tableView.deleteSections(IndexSet(integer: indexPath.section), with: .left)
                                
                            case .failure(let error):
                                print("Failed to remove member: \(error.localizedDescription)")
                                // Put the cell back if the network request fails
                                self.tableView.reloadSections(IndexSet(integer: indexPath.section), with: .automatic)
                            }
                        }
                    }
                }
                
                alert.addAction(cancelAction)
                alert.addAction(deleteAction)
                
                // 4. Show the alert!
                present(alert, animated: true)
            }
        }
        
        // MARK: - Navigation
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == SegueIdentifiers.goToMemberDetails,
               let destinationVC = segue.destination as? FamilyMemberViewController,
               let selectedMember = sender as? FamilyMember {
                destinationVC.familyMember = selectedMember
            }
        }
    }
