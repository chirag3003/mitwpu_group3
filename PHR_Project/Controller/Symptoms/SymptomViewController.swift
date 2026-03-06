import UIKit

class SymptomViewController: UIViewController, UITableViewDelegate,
    UITableViewDataSource, FamilyMemberDataScreen, SharedWriteAccessReceiving
{

    var symptomsData: [Symptom] = []
    var isDeleting = false
    var familyMember: FamilyMember?
    var canEditSharedData = false
    
    // MARK: - Outlets
    
    @IBOutlet weak var symptomTableView: UITableView!

    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Data setup
        if let member = familyMember {
            loadSharedSymptoms(for: member)
        } else {
            symptomsData = SymptomService.shared.getSymptoms()
        }

        // Table view setup
        symptomTableView.dataSource = self
        symptomTableView.delegate = self
        symptomTableView.separatorStyle = .none

        // Notifs
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateSymptoms),
            name: NSNotification.Name(NotificationNames.symptomsUpdated),
            object: nil
        )

        if familyMember != nil {
            self.title = "\(familyMember!.name)'s Symptoms"
        } else {
            self.title = "Symptoms"
        }

        if familyMember == nil || canEditSharedData {
            setupLongPressGesture()
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func setupLongPressGesture() {
            let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
            symptomTableView.addGestureRecognizer(longPress)
        }

        // NEW: Handle Gesture
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
            guard familyMember == nil || canEditSharedData else { return }
            if gestureRecognizer.state == .began {
                let touchPoint = gestureRecognizer.location(in: symptomTableView)
                if let indexPath = symptomTableView.indexPathForRow(at: touchPoint) {
                    
                    let selectedSymptom = symptomsData[indexPath.row]
                    
                    // Assuming you have a Segue from this VC to AddSymptomTableViewController
                    // You need to ensure the Segue Identifier matches your storyboard.
                    // If you don't have a segue identifier yet, name it "ShowAddSymptom" in Storyboard.
                    // Or perform navigation programmatically if you prefer.
                    performSegue(withIdentifier: "ShowAddSymptom", sender: selectedSymptom)
                }
            }
        }

        // NEW: Prepare for Segue to pass data
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "ShowAddSymptom" {
                if let navVC = segue.destination as? UINavigationController,
                   let destVC = navVC.topViewController as? AddSymptomTableViewController {
                    
                    // If sender is a Symptom, we are editing
                    destVC.familyMember = familyMember
                    if let symptomToEdit = sender as? Symptom {
                        destVC.symptomToEdit = symptomToEdit
                    }
                } else if let destVC = segue.destination as? AddSymptomTableViewController {
                    // Handle case where it might not be wrapped in Nav Controller
                    destVC.familyMember = familyMember
                    if let symptomToEdit = sender as? Symptom {
                        destVC.symptomToEdit = symptomToEdit
                    }
                }
            }
        }

    // MARK: - TableView Methods

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)
        -> Int
    {
        return symptomsData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell
    {
        
        let cell =
            tableView.dequeueReusableCell(
                withIdentifier: CellIdentifiers.symptomCell,
                for: indexPath
            ) as! SymptomTableViewCell

     
        let currentSymptom = symptomsData[indexPath.row]

        // Configure cell
        cell.configure(with: currentSymptom)

        cell.selectionStyle = .none
        return cell

    }

    func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath
    ) {
        if editingStyle == .delete {
            if let member = familyMember {
                guard canEditSharedData else { return }
                let symptom = symptomsData[indexPath.row]
                guard let apiId = symptom.apiID else { return }
                isDeleting = true
                SharedDataService.shared.deleteSymptom(
                    for: member.userId,
                    symptomId: apiId
                ) { [weak self] result in
                    guard let self = self else { return }
                    switch result {
                    case .success:
                        self.symptomsData.remove(at: indexPath.row)
                        self.symptomTableView.deleteRows(
                            at: [indexPath],
                            with: .fade
                        )
                    case .failure(let error):
                        print("Error deleting shared symptom: \(error)")
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        self.isDeleting = false
                    }
                }
                return
            }

            isDeleting = true
            SymptomService.shared.deleteSymptom(at: indexPath.row)
            symptomsData.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.isDeleting = false
            }
        }
    }

    func reloadData() {
            if let member = familyMember {
                loadSharedSymptoms(for: member)
            } else {
                // 1. Get the latest reference from the Service
                // Since 'symptoms' is a Value Type (Array), we must re-assign it.
                symptomsData = SymptomService.shared.getSymptoms()
                
                // 2. Reload the table view
                DispatchQueue.main.async {
                    self.symptomTableView.reloadData()
                }
            }
        }
        
        // Also add this to ensure the view stays fresh
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            reloadData()
        }
    
        @objc func updateSymptoms() {
        // If we are currently deleting a row, don't reload to avoid animation conflicts
        if isDeleting { return }
        
        // Otherwise, refresh the list
        reloadData()
    }

    private func loadSharedSymptoms(for member: FamilyMember) {
        SharedDataService.shared.fetchSymptoms(for: member.userId) { [weak self] result in
            switch result {
            case .success(let symptoms):
                self?.symptomsData = symptoms
                self?.symptomTableView.reloadData()
            case .failure(let error):
                print("Error fetching shared symptoms: \(error)")
            }
        }
    }

}
