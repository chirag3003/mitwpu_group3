import UIKit

class FamilyPermissionsTableViewController: UITableViewController {

    // MARK: - Outlets

    @IBOutlet weak var readWriteSwitch: UISwitch!
   
    @IBOutlet weak var documentsSwitch: UISwitch!
    @IBOutlet weak var mealLogsSwitch: UISwitch!
    @IBOutlet weak var symptomLogsSwitch: UISwitch!
    @IBOutlet weak var trendsSwitch: UISwitch!
    @IBOutlet weak var nameDetailLabel: UILabel!
    @IBOutlet weak var contactDetailLabel: UILabel!
    
    var selectedContact: Contact?
    var selectedMember: FamilyMember?
    private var existingPermission: FamilyPermission?

        override func viewDidLoad() {
            super.viewDidLoad()

            // 1. Set Default State
            readWriteSwitch.isOn = true
            
            // NEW: Populate the labels with the passed data
            if let member = selectedMember {
                nameDetailLabel.text = member.name
                contactDetailLabel.text = member.phoneNumber ?? ""
                fetchPermissions(for: member)
            } else if let contact = selectedContact {
                nameDetailLabel.text = contact.name
                contactDetailLabel.text = contact.phoneNum
            }
        }
    // MARK: - Actions

    @IBAction func tickButtonTapped(_ sender: UIBarButtonItem) {
        guard let member = selectedMember else {
            dismiss(animated: true)
            return
        }

        let flags = FamilyPermissionFlags(
            documents: documentsSwitch.isOn,
            symptoms: symptomLogsSwitch.isOn,
            meals: mealLogsSwitch.isOn,
            glucose: trendsSwitch.isOn,
            allergies: false,
            water: false
        )

        guard let familyId = FamilyService.shared.getCurrentFamilyId() else {
            showErrorAlert(message: "Please select a family first.")
            return
        }

        guard let currentUserId = AuthService.shared.currentUser?.id,
            currentUserId != member.userId
        else {
            showErrorAlert(message: "You cannot edit your own permissions.")
            return
        }

        if existingPermission == nil {
            FamilyPermissionsService.shared.createPermissions(for: member.userId) {
                [weak self] permission in
                guard let self = self else { return }
                if permission == nil {
                    self.showErrorAlert(message: "Failed to create permissions.")
                    return
                }
                self.existingPermission = permission
                self.updatePermissions(
                    familyId: familyId,
                    memberId: member.userId,
                    flags: flags
                )
            }
        } else {
            updatePermissions(familyId: familyId, memberId: member.userId, flags: flags)
        }
    }

    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }

    private func fetchPermissions(for member: FamilyMember) {
        FamilyPermissionsService.shared.getPermissions(for: member.userId) { [weak self] permission in
            guard let self = self else { return }
            if member.userId == AuthService.shared.currentUser?.id {
                self.readWriteSwitch.isEnabled = false
                self.documentsSwitch.isEnabled = false
                self.mealLogsSwitch.isEnabled = false
                self.symptomLogsSwitch.isEnabled = false
                self.trendsSwitch.isEnabled = false
                self.readWriteSwitch.isOn = false
                self.documentsSwitch.isOn = false
                self.mealLogsSwitch.isOn = false
                self.symptomLogsSwitch.isOn = false
                self.trendsSwitch.isOn = false
                return
            }
            if let permission = permission {
                self.existingPermission = permission
                self.readWriteSwitch.isOn = permission.write
                self.documentsSwitch.isOn = permission.permissions.documents
                self.mealLogsSwitch.isOn = permission.permissions.meals
                self.symptomLogsSwitch.isOn = permission.permissions.symptoms
                self.trendsSwitch.isOn = permission.permissions.glucose
            } else {
                self.readWriteSwitch.isOn = false
                self.documentsSwitch.isOn = false
                self.mealLogsSwitch.isOn = false
                self.symptomLogsSwitch.isOn = false
                self.trendsSwitch.isOn = false
            }
        }
    }

    private func updatePermissions(
        familyId: String,
        memberId: String,
        flags: FamilyPermissionFlags
    ) {
        FamilyPermissionsService.shared.updatePermissions(
            familyId: familyId,
            permissionTo: memberId,
            write: readWriteSwitch.isOn,
            permissions: flags
        ) { [weak self] permission in
            if permission == nil {
                self?.showErrorAlert(message: "Failed to update permissions.")
                return
            }
            self?.dismiss(animated: true)
        }
    }

    private func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    //Custom Header
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
            if section == 1 {
                let headerView = UIView()
                headerView.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 40)

                let label = UILabel()
                label.text = "Allow Access To"
                label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
                label.textColor = .secondaryLabel
                label.translatesAutoresizingMaskIntoConstraints = false
                headerView.addSubview(label)

                NSLayoutConstraint.activate([
                    label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
                    label.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -8),
                ])

                return headerView
            }
            return super.tableView(tableView, viewForHeaderInSection: section)
        }

        override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            return section == 1 ? 40 : 40
        }

        @objc func turnOnAllTapped() {
            documentsSwitch.setOn(true, animated: true)
            mealLogsSwitch.setOn(true, animated: true)
            symptomLogsSwitch.setOn(true, animated: true)
            trendsSwitch.setOn(true, animated: true)
        }
    }
