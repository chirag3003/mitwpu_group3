import UIKit

class AllergyViewController: UIViewController, UITableViewDelegate,
    UITableViewDataSource
{

    var allergies: [Allergy] = []

    // MARK: - Outlets

    @IBOutlet weak var allergiesTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        allergies = AllergyService.shared.fetchAllergies()
        allergiesTableView.dataSource = self
        allergiesTableView.delegate = self

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(refreshData),
            name: NSNotification.Name("AllergiesUpdated"),
            object: nil
        )
    }

    @objc func refreshData() {
        self.allergies = AllergyService.shared.fetchAllergies()
        self.allergiesTableView.reloadData()
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
            AllergyService.shared.deleteAllergy(
                at: indexPath.row,
                notify: false
            )
            allergies.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}
