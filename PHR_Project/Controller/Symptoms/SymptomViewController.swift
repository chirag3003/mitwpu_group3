import UIKit

class SymptomViewController: UIViewController, UITableViewDelegate,
    UITableViewDataSource, FamilyMemberDataScreen
{

    var symptomsData: [Symptom] = []
    var isDeleting = false
    var familyMember: FamilyMember?
    
    // MARK: - Outlets
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var symptomTableView: UITableView!

    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Data setup
        symptomsData = SymptomService.shared.getSymptoms()

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

        setupLongPressGesture()
    }
    
    func setupLongPressGesture() {
            let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
            symptomTableView.addGestureRecognizer(longPress)
        }

        // NEW: Handle Gesture
        @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
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
                    if let symptomToEdit = sender as? Symptom {
                        destVC.symptomToEdit = symptomToEdit
                    }
                } else if let destVC = segue.destination as? AddSymptomTableViewController {
                    // Handle case where it might not be wrapped in Nav Controller
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

            isDeleting = true
            // Step A: Update the Data Source (Persistence)
            // You must delete the item from your Service/Database first!
            // Example: SymptomService.shared.deleteSymptom(at: indexPath.row)
            SymptomService.shared.deleteSymptom(at: indexPath.row)
            // Step B: Remove from the local array
            symptomsData.remove(at: indexPath.row)

            // Step C: Update the Table View with animation
            tableView.deleteRows(at: [indexPath], with: .fade)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.isDeleting = false
            }
        }
    }

    func reloadData() {
            // 1. Get the latest reference from the Service
            // Since 'symptoms' is a Value Type (Array), we must re-assign it.
            symptomsData = SymptomService.shared.getSymptoms()
            
            // 2. Reload the table view
            DispatchQueue.main.async {
                self.symptomTableView.reloadData()
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

}
