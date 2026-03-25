import UIKit

class GenerateSummaryTableViewController: UITableViewController,
    FamilyMemberDataScreen
{

    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    @IBOutlet weak var symptomsSwitch: UISwitch!
    @IBOutlet weak var reportsSwitch: UISwitch!
    @IBOutlet weak var prescriptionsSwitch: UISwitch!
    @IBOutlet weak var trendsSwitch: UISwitch!
    @IBOutlet weak var mealsSwitch: UISwitch!
    @IBOutlet weak var notesTextField: UITextField!
    @IBOutlet weak var generateSummaryButton: UIButton!

    var familyMember: FamilyMember?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextField()
        setupKeyboardDismissal()
    }

    // MARK: - Setup

    private func setupTextField() {
        notesTextField.borderStyle = .none
    }

    override func tableView(
        _ tableView: UITableView,
        viewForHeaderInSection section: Int
    ) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .clear

        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        switch section {
        case 0: titleLabel.text = "Time Range"
        case 1: titleLabel.text = "Select Data Fields"
        case 2: titleLabel.text = "Additional Notes"
        default: return nil
        }

        headerView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(
                equalTo: headerView.leadingAnchor,
                constant: 20
            ),
            titleLabel.bottomAnchor.constraint(
                equalTo: headerView.bottomAnchor,
                constant: -8
            ),
            titleLabel.topAnchor.constraint(
                equalTo: headerView.topAnchor,
                constant: 15
            ),
        ])

        return headerView
    }

    // MARK: - Keyboard Handling

    private func setupKeyboardDismissal() {
        tableView.keyboardDismissMode = .interactive
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissKeyboard)
        )
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: - Actions

    @IBAction func onGenerateSummary(_ sender: Any) {
        generateSummaryButton.isEnabled = false
        generateSummaryButton.setTitle("Generating...", for: .normal)
        showLoader(true)

        let include = SummaryInclude(
            glucose: trendsSwitch.isOn,
            symptoms: symptomsSwitch.isOn,
            meals: mealsSwitch.isOn,
            documents: reportsSwitch.isOn || prescriptionsSwitch.isOn,
            activity: true // Always include activity if steps are synced
        )

        let completion: (String?) -> Void = { [weak self] pdfURLString in
            guard let self = self else { return }

            self.showLoader(false)
            self.generateSummaryButton.isEnabled = true
            self.generateSummaryButton.setTitle(
                "Generate Summary",
                for: .normal
            )
            if let urlString = pdfURLString {
                self.performSegue(
                    withIdentifier: "healthReportSegue",
                    sender: urlString
                )
            } else {
                self.showAlert(
                    title: "Error",
                    message:
                        "Could not generate health summary. Please try again."
                )
            }
        }

        if let member = familyMember {
            InsightsService.shared.generateSharedSummary(
                for: member.userId,
                startDate: startDatePicker.date,
                endDate: endDatePicker.date,
                include: include,
                completion: completion
            )
        } else {
            InsightsService.shared.generateSummary(
                startDate: startDatePicker.date,
                endDate: endDatePicker.date,
                include: include,
                completion: completion
            )
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let navController = segue.destination as? UINavigationController,
              let vc = navController.topViewController as? HealthReportViewController,
              let pdfURL = sender as? String else { return }
        vc.remotePDFURL = pdfURL
    }
}
