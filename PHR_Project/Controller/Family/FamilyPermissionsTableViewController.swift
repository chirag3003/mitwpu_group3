import UIKit

class FamilyPermissionsTableViewController: UITableViewController {

    // MARK: - Outlets

    @IBOutlet weak var readWriteSwitch: UISwitch!
   
    @IBOutlet weak var documentsSwitch: UISwitch!
    @IBOutlet weak var mealLogsSwitch: UISwitch!
    @IBOutlet weak var symptomLogsSwitch: UISwitch!
    @IBOutlet weak var trendsSwitch: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()

        // 1. Set Default State
        readWriteSwitch.isOn = true
        

        
    }

    // Toggle restriction


    // MARK: - Actions

    @IBAction func tickButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }

    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }

    //Custom Header
    override func tableView(
        _ tableView: UITableView,
        viewForHeaderInSection section: Int
    ) -> UIView? {

        if section == 1 {
            let headerView = UIView()
            headerView.frame = CGRect(
                x: 0,
                y: 0,
                width: tableView.frame.width,
                height: 40
            )

            // Custom Header
            let label = UILabel()
            label.text = "Allow Access To"
            label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
            label.textColor = .secondaryLabel  // Standard Gray Color
            label.translatesAutoresizingMaskIntoConstraints = false
            headerView.addSubview(label)

            // Constraints
            NSLayoutConstraint.activate([

                label.leadingAnchor.constraint(
                    equalTo: headerView.leadingAnchor,
                    constant: 16
                ),
                label.bottomAnchor.constraint(
                    equalTo: headerView.bottomAnchor,
                    constant: -8
                ),

            ])

            return headerView
        }

        return super.tableView(tableView, viewForHeaderInSection: section)
    }

    override func tableView(
        _ tableView: UITableView,
        heightForHeaderInSection section: Int
    ) -> CGFloat {
        return section == 1 ? 40 : 40
    }

    // MARK: - Actions

    @objc func turnOnAllTapped() {

        documentsSwitch.setOn(true, animated: true)
        mealLogsSwitch.setOn(true, animated: true)
        symptomLogsSwitch.setOn(true, animated: true)
        trendsSwitch.setOn(true, animated: true)
    }

}
