import UIKit

class FamilyViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
  
    

    // MARK: - Outlets

   
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addButton: UIBarButtonItem!

    private var familyData: [FamilyMember] = []
        private var currentFamily: Family?

        override func viewDidLoad() {
            super.viewDidLoad()
            
            // This keeps the native iOS gray background for inset grouped tables
            view.backgroundColor = .systemGroupedBackground
            tableView.backgroundColor = .clear

            setupTableView()
            setupAddMenu()
            setupObservers()
            refreshFamilies()
        }

        deinit {
            NotificationCenter.default.removeObserver(self)
        }

        // MARK: - Setup
        
        private func setupData() {
            currentFamily = FamilyService.shared.getCurrentFamily()
            familyData = FamilyService.shared.getMembersForCurrentFamily()
            navigationItem.title = currentFamily?.name ?? "Family"
        }
    
    private func setupObservers() {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(handleFamiliesUpdated),
                name: NSNotification.Name(NotificationNames.familiesUpdated),
                object: nil
            )
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(handleMembersUpdated),
                name: NSNotification.Name(NotificationNames.familyMembersUpdated),
                object: nil
            )
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(handleFamilySelectionChanged),
                name: NSNotification.Name(NotificationNames.familySelectionUpdated),
                object: nil
            )
        }

        private func setupTableView() {
            tableView.delegate = self
            tableView.dataSource = self
            
            // Removed the complex compositional layout code! Table Views handle this natively.
            // If you are using a custom XIB cell, uncomment and update this line:
            // tableView.register(UINib(nibName: "YourCustomCellNibName", bundle: nil), forCellReuseIdentifier: "FamilyMemberCell")
        }

        // MARK: - Table View Data Source & Delegate

        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return familyData.count
        }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "familyMember_cell", for: indexPath)
            let member = familyData[indexPath.row]
            
            var content = cell.defaultContentConfiguration()
            content.text = member.name
            
            // placeholder image with explicit size configuration
            let symbolConfig = UIImage.SymbolConfiguration(pointSize: 60)
            let placeholder = UIImage(systemName: "person.circle.fill", withConfiguration: symbolConfig)?.withTintColor(.systemGray3, renderingMode: .alwaysOriginal)
            content.image = placeholder
            
            // image formatting - updated to 60x60
            content.imageProperties.maximumSize = CGSize(width: 60, height: 60)
            content.imageProperties.reservedLayoutSize = CGSize(width: 60, height: 60)
            content.imageProperties.cornerRadius = 30
            
            cell.contentConfiguration = content
            
            // load profile image
            if !member.imageName.isEmpty, let url = URL(string: member.imageName) {
                URLSession.shared.dataTask(with: url) { data, response, error in
                    guard let data = data, error == nil, let loadedImage = UIImage(data: data) else { return }
                    
                    DispatchQueue.main.async {
                        if tableView.indexPath(for: cell) == indexPath {
                            var updatedContent = cell.defaultContentConfiguration()
                            updatedContent.text = member.name
                            updatedContent.image = loadedImage
                            
                            // matched 60x60 formatting for the downloaded image
                            updatedContent.imageProperties.maximumSize = CGSize(width: 60, height: 60)
                            updatedContent.imageProperties.reservedLayoutSize = CGSize(width: 60, height: 60)
                            updatedContent.imageProperties.cornerRadius = 30
                            
                            cell.contentConfiguration = updatedContent
                        }
                    }
                }.resume()
            }
            
            return cell
        }

        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            tableView.deselectRow(at: indexPath, animated: true)

            let selectedMember = familyData[indexPath.row]
            performSegue(
                withIdentifier: SegueIdentifiers.goToMemberDetails,
                sender: selectedMember
            )
        }

        // MARK: - Observers & Refreshing
        
        private func refreshFamilies() {
            FamilyService.shared.fetchFamilies { [weak self] success in
                guard let self = self else { return }
                self.setupData()
                self.tableView.reloadData()
                
                if success, let familyId = FamilyService.shared.getCurrentFamilyId() {
                    FamilyService.shared.fetchFamilyMembers(familyId: familyId) { _ in
                        self.setupData()
                        self.tableView.reloadData()
                    }
                }
            }
        }

        @objc private func handleFamiliesUpdated() {
            setupData()
            tableView.reloadData()
        }

        @objc private func handleMembersUpdated() {
            setupData()
            tableView.reloadData()
        }

        @objc private func handleFamilySelectionChanged() {
            setupData()
            tableView.reloadData()
            if let familyId = FamilyService.shared.getCurrentFamilyId() {
                FamilyService.shared.fetchFamilyMembers(familyId: familyId, completion: nil)
            }
        }
        
        // MARK: - Actions & Segues
        // (Your existing setupAddMenu and prepareForSegue code remains exactly the same below!)
        
        private func setupAddMenu() {
            let addMemberAction = UIAction(
                title: "Add Member to current Family",
                image: UIImage(systemName: "person.badge.plus")
            ) { [weak self] _ in
                if FamilyService.shared.getCurrentFamilyId() == nil {
                    // Assuming you have an extension or method for showAlert
                    self?.showAlert(
                        title: "No Family",
                        message: "Create a family first to add members."
                    )
                    return
                }
                self?.performSegue(withIdentifier: "GoToAddMember", sender: nil)
            }

            let createFamilyAction = UIAction(
                title: "Create new Family",
                image: UIImage(systemName: "person.2.fill")
            ) { [weak self] _ in
                self?.performSegue(withIdentifier: "GoToAddFamily", sender: nil)
            }

            let menu = UIMenu(children: [addMemberAction, createFamilyAction])
            addButton.menu = menu
        }

        @IBAction func familySwitchButtonTapped(_ sender: UIBarButtonItem) {
            performSegue(withIdentifier: "familySwitchSegue", sender: nil)
        }

        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == SegueIdentifiers.goToMemberDetails {
                if let destinationVC = segue.destination
                    as? FamilyMemberViewController
                {
                    let selectedMember = sender as? FamilyMember
                    destinationVC.familyMember = selectedMember
                }
            }

            if segue.identifier == "familySwitchSegue" {
                if let destinationVC = segue.destination as? FamilySwitchTableViewController {
                    if let sheet = destinationVC.sheetPresentationController {
                        sheet.detents = [.medium(), .large()]
                        sheet.prefersGrabberVisible = true
                        sheet.preferredCornerRadius = 24
                    }
                }
            }
        }
    }
