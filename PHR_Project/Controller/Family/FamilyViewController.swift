import UIKit

class FamilyViewController: UIViewController, UITableViewDelegate,
    UITableViewDataSource
{

    // MARK: - Outlets

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addButton: UIBarButtonItem!

    private var families: [Family] = []

        override func viewDidLoad() {
            super.viewDidLoad()
            view.backgroundColor = .systemGroupedBackground
            tableView.backgroundColor = .clear
            
            setupTableView()
            setupAddMenu()
            setupObservers()
        }
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            refreshFamilies()
        }

        deinit {
            NotificationCenter.default.removeObserver(self)
        }

        // MARK: - Setup
        private func setupTableView() {
            tableView.delegate = self
            tableView.dataSource = self
            navigationItem.title = "My Families"
            
            // Matches the floating style of the members list
            tableView.rowHeight = 75
            tableView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 20, right: 0)
        }

        private func setupObservers() {
            NotificationCenter.default.addObserver(self, selector: #selector(refreshFamilies), name: NSNotification.Name(NotificationNames.familiesUpdated), object: nil)
        }

        @objc private func refreshFamilies() {
            FamilyService.shared.fetchFamilies { [weak self] _ in
                guard let self = self else { return }
                self.families = FamilyService.shared.getFamilies()
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }

        // MARK: - Actions
        private func setupAddMenu() {
            let createFamilyAction = UIAction(
                title: "Create new Family",
                image: UIImage(systemName: "person.2.fill")
            ) { [weak self] _ in
                self?.performSegue(withIdentifier: "GoToAddFamily", sender: nil)
            }

            let menu = UIMenu(children: [createFamilyAction])
            addButton.menu = menu
        }

        // MARK: - Table View Data Source & Delegate
        
        // 1. Give every family their own section for the floating cell look
        func numberOfSections(in tableView: UITableView) -> Int {
            return families.count
        }

        // 2. Only ONE row per section
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return 1
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "family_cell", for: indexPath)
            
            // 3. Grab the family using indexPath.section
            let family = families[indexPath.section]
            
            var content = cell.defaultContentConfiguration()
            content.text = family.name
            content.textProperties.font = UIFont.systemFont(ofSize: 18, weight: .medium)
            cell.contentConfiguration = content
            
            cell.accessoryType = .disclosureIndicator
            return cell
        }

        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            tableView.deselectRow(at: indexPath, animated: true)
            
            // 4. Grab the family using indexPath.section here too
            let selectedFamily = families[indexPath.section]
            
            FamilyService.shared.setCurrentFamily(id: selectedFamily.apiID)
            performSegue(withIdentifier: "GoToFamilyMembers", sender: selectedFamily)
        }
        
        // MARK: - Cell Spacing
        func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            return 8
        }
        
        func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
            return 8
        }

    // MARK: - Swipe Actions
        
        func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
            
            // Create the swipe action
            let leaveAction = UIContextualAction(style: .destructive, title: "Leave") { [weak self] (action, view, completionHandler) in
                guard let self = self else { return }
                
                let familyToLeave = self.families[indexPath.section]
                guard let familyId = familyToLeave.apiID else {
                    completionHandler(false)
                    return
                }
                
                // Show the confirmation alert
                let alert = UIAlertController(
                    title: "Exit Family",
                    message: "Are you sure you want to leave '\(familyToLeave.name)'?",
                    preferredStyle: .alert
                )
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
                    completionHandler(false) // Swipes the cell back if they cancel
                }
                
                let confirmAction = UIAlertAction(title: "Leave", style: .destructive) { _ in
                    FamilyService.shared.leaveFamily(familyId: familyId) { success in
                        DispatchQueue.main.async {
                            if success {
                                self.families.remove(at: indexPath.section)
                                self.tableView.deleteSections(IndexSet(integer: indexPath.section), with: .left)
                                completionHandler(true)
                            } else {
                                print("Failed to leave family")
                                completionHandler(false)
                            }
                        }
                    }
                }
                
                alert.addAction(cancelAction)
                alert.addAction(confirmAction)
                self.present(alert, animated: true)
            }
            
            // Optional: Add a nice icon to the swipe button
            leaveAction.image = UIImage(systemName: "rectangle.portrait.and.arrow.right")
            leaveAction.backgroundColor = .systemRed
            
            // Return the configuration
            return UISwipeActionsConfiguration(actions: [leaveAction])
        }

        // MARK: - Navigation
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "GoToFamilyMembers",
               let destinationVC = segue.destination as? FamilyMembersListViewController,
               let selectedFamily = sender as? Family {
                destinationVC.family = selectedFamily
            }
        }
    }
