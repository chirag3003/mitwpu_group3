import UIKit

class AllergyViewController: UIViewController, UITableViewDelegate,
    UITableViewDataSource, FamilyMemberDataScreen, SharedWriteAccessReceiving
{

    var allergies: [Allergy] = []
    var familyMember: FamilyMember?
    var canEditSharedData = false

    @IBOutlet weak var plusButton: UIBarButtonItem!
    // MARK: - Outlets

    @IBOutlet weak var allergiesTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        if familyMember != nil {
            self.title = "\(familyMember!.name)'s Allergies"
        } else {
            self.title = "Allergies"
        }

        if let member = familyMember {
            loadSharedAllergies(for: member)
        } else {
            allergies = AllergyService.shared.fetchAllergies()
        }
        allergiesTableView.dataSource = self
        allergiesTableView.delegate = self

        if familyMember == nil {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(refreshData),
                name: NSNotification.Name(NotificationNames.allergiesUpdated),
                object: nil
            )
        } else {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(refreshSharedData(_:)),
                name: NSNotification.Name(
                    NotificationNames.sharedAllergiesUpdated
                ),
                object: nil
            )
        }

        updateEditingAccess()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func refreshData() {
        if let member = familyMember {
            loadSharedAllergies(for: member)
        } else {
            self.allergies = AllergyService.shared.fetchAllergies()
            self.allergiesTableView.reloadData()
        }
    }

    @objc private func refreshSharedData(_ notification: Notification) {
        guard let member = familyMember else { return }
        if let userId = notification.userInfo?["userId"] as? String,
            userId != member.userId
        {
            return
        }
        loadSharedAllergies(for: member)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)
        -> Int
    {
        return allergies.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell
    {
        let cell =
            tableView.dequeueReusableCell(
                withIdentifier: CellIdentifiers.allergyCell,
                for: indexPath
            ) as! AllergyTableViewCell
        cell.configureCell(with: allergies[indexPath.row])

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
                let allergy = allergies[indexPath.row]
                guard let apiId = allergy.apiID else { return }
                SharedDataService.shared.deleteAllergy(
                    for: member.userId,
                    allergyId: apiId
                ) { [weak self] result in
                    switch result {
                    case .success:
                        self?.allergies.remove(at: indexPath.row)
                        tableView.deleteRows(at: [indexPath], with: .fade)
                    case .failure(let error):
                        print("Error deleting shared allergy: \(error)")
                    }
                }
            } else {
                AllergyService.shared.deleteAllergy(
                    at: indexPath.row,
                    notify: false
                )
                allergies.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }
    @IBAction func onPlusButtonClick(_ sender: Any) {
        guard familyMember == nil || canEditSharedData else { return }
        performSegue(withIdentifier: "addAllergySegue", sender: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let navController = segue.destination as? UINavigationController,
            let addVC = navController.topViewController
                as? AddAllergyTableViewController
        {
            addVC.familyMember = familyMember
            addVC.canEditSharedData = canEditSharedData
        } else if let addVC = segue.destination
            as? AddAllergyTableViewController
        {
            addVC.familyMember = familyMember
            addVC.canEditSharedData = canEditSharedData
        }
    }

    private func loadSharedAllergies(for member: FamilyMember) {
        SharedDataService.shared.fetchAllergies(for: member.userId) {
            [weak self] result in
            switch result {
            case .success(let allergies):
                self?.allergies = allergies
                self?.allergiesTableView.reloadData()
            case .failure(let error):
                print("Error fetching shared allergies: \(error)")
            }
        }
    }

    private func updateEditingAccess() {
        if familyMember == nil {
            plusButton.isEnabled = true
        } else {
            plusButton.isEnabled = canEditSharedData
        }
    }
}
