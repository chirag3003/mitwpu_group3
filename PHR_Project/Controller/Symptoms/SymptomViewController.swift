import UIKit

class SymptomViewController: UIViewController, UITableViewDelegate,
    UITableViewDataSource, FamilyMemberDataScreen
{

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var symptomTableView: UITableView!

    var symptomsData: [Symptom] = []
    
    var isDeleting = false
    
    var familyMember: FamilyMember?

    override func viewDidLoad() {
        super.viewDidLoad()
        // data setup
        symptomsData = SymptomService.shared.getSymptoms()
        
        // table view setup
        symptomTableView.dataSource = self
        symptomTableView.delegate = self

        // UI Cleanup
        symptomTableView.separatorStyle = .none
        
        //setting up event listeners
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateSymptoms),
            name: NSNotification.Name(NotificationNames.symptomsUpdated),
            object: nil
        )

        if(familyMember != nil){
            self.title = "\(familyMember!.name)'s Symptoms"
        } else {
            self.title = "Symptoms"
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
        // Ensure Identifier in Storyboard is "symptom_cell"
        let cell =
            tableView.dequeueReusableCell(
                withIdentifier: CellIdentifiers.symptomCell,
                for: indexPath
            ) as! SymptomTableViewCell

        // Get specific symptom
        let currentSymptom = symptomsData[indexPath.row]

        // Configure cell
        cell.configure(with: currentSymptom)

        cell.selectionStyle = .none
        return cell
        
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
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
        symptomsData = SymptomService.shared.getSymptoms()
        symptomTableView.reloadData()
    }

    @objc func updateSymptoms() {
        if isDeleting {
            return
        }
        reloadData()
        // Update your labels here...
    }

}
