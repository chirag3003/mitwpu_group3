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
            
            // Gives the cells a larger, more substantial size
            tableView.rowHeight = 75
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
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return families.count
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "family_cell", for: indexPath)
            
            // Upgraded to UIListContentConfiguration for better padding and sizing
            var content = cell.defaultContentConfiguration()
            content.text = families[indexPath.row].name
            content.textProperties.font = UIFont.systemFont(ofSize: 18, weight: .medium)
            cell.contentConfiguration = content
            
            cell.accessoryType = .disclosureIndicator
            return cell
        }

        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            tableView.deselectRow(at: indexPath, animated: true)
            let selectedFamily = families[indexPath.row]
            
            FamilyService.shared.setCurrentFamily(id: selectedFamily.apiID)
            performSegue(withIdentifier: "GoToFamilyMembers", sender: selectedFamily)
        }

        // MARK: - Context Menu (Exit Family)
        func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
            return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
                let exitAction = UIAction(
                    title: "Exit Family",
                    image: UIImage(systemName: "rectangle.portrait.and.arrow.right"),
                    attributes: .destructive
                ) { [weak self] _ in
                    guard let self = self else { return }
                    let family = self.families[indexPath.row]
                    if let familyId = family.apiID {
                        FamilyService.shared.leaveFamily(familyId: familyId) { success in
                            guard success else { return }
                            self.refreshFamilies()
                        }
                    }
                }
                return UIMenu(title: "", children: [exitAction])
            }
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
