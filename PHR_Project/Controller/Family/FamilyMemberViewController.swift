import UIKit

protocol FamilyMemberDataScreen {
    var familyMember: FamilyMember? { get set }
}

class FamilyMemberViewController: UIViewController {
    var familyMember: FamilyMember?
    private var permissions = FamilyPermissionFlags(
        documents: false,
        symptoms: false,
        meals: false,
        glucose: false,
        allergies: true,
        water: false
    )
    private var writeAccess = false
    private var isUpdating = false
    private var sharedOptionsList: [(title: String, segue: String)] = []

    // MARK: Outlets
    @IBOutlet weak var pfpImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!

    // Data Models
    let accessOptions = [
        "Documents", "Meal Logs", "Symptom Logs", "Glucose", "Water",
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        // table view
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()

        // Set member details
        nameLabel.text = familyMember?.name ?? "Family Member"

        // profile image changes
        pfpImage.addFullRoundedCorner()
        pfpImage.setImageFromURL(url: familyMember?.imageName ?? "")

        fetchPermissions()
        fetchSharedPermissions()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if var destination = segue.destination as? FamilyMemberDataScreen {
            destination.familyMember = self.familyMember
        }
    }

    private func fetchPermissions() {
        guard let member = familyMember else { return }
        FamilyPermissionsService.shared.getPermissions(for: member.userId) {
            [weak self] permission in
            guard let self = self, let permission = permission else { return }
            self.permissions = FamilyPermissionFlags(
                documents: permission.permissions.documents,
                symptoms: permission.permissions.symptoms,
                meals: permission.permissions.meals,
                glucose: permission.permissions.glucose,
                allergies: true,
                water: permission.permissions.water
            )
            self.writeAccess = permission.write
            self.tableView.reloadData()
        }
    }

    private func fetchSharedPermissions() {
        guard let member = familyMember else { return }
        FamilyPermissionsService.shared.getPermissionsFrom(userId: member.userId) {
            [weak self] permission in
            guard let self = self else { return }
            self.sharedOptionsList = self.buildSharedOptions(from: permission)
            self.tableView.reloadSections(IndexSet(integer: 2), with: .automatic)
        }
    }

    private func buildSharedOptions(from permission: FamilyPermission?)
        -> [(title: String, segue: String)]
    {
        var options: [(title: String, segue: String)] = []

        if let flags = permission?.permissions {
            if flags.documents {
                options.append(("Documents", "familyDocumentsSegue"))
            }
            if flags.meals {
                options.append(("Meal Logs", "familyMealsSegue"))
            }
            if flags.symptoms {
                options.append(("Symptom Logs", "familySymptomsSegue"))
            }
            if flags.glucose {
                options.append(("Glucose", "familyGlucoseSegue"))
            }
            if flags.water {
                options.append(("Water", "familyWaterSegue"))
            }
        }

        options.append(("Allergies", "familyAllergiesSegue"))
        return options
    }

    @objc private func permissionSwitchChanged(_ sender: UISwitch) {
        guard !isUpdating else { return }
        switch sender.tag {
        case 0:
            permissions.documents = sender.isOn
        case 1:
            permissions.meals = sender.isOn
        case 2:
            permissions.symptoms = sender.isOn
        case 3:
            permissions.glucose = sender.isOn
        case 4:
            permissions.water = sender.isOn
        case 100:
            writeAccess = sender.isOn
        default:
            break
        }
        updatePermissions()
    }

    private func updatePermissions() {
        guard let member = familyMember,
            let familyId = FamilyService.shared.getCurrentFamilyId()
        else { return }

        let previousPermissions = permissions
        let previousWrite = writeAccess

        isUpdating = true
        tableView.isUserInteractionEnabled = false

        let enforcedPermissions = FamilyPermissionFlags(
            documents: permissions.documents,
            symptoms: permissions.symptoms,
            meals: permissions.meals,
            glucose: permissions.glucose,
            allergies: true,
            water: permissions.water
        )

        FamilyPermissionsService.shared.updatePermissions(
            familyId: familyId,
            permissionTo: member.userId,
            write: writeAccess,
            permissions: enforcedPermissions
        ) { [weak self] permission in
            guard let self = self else { return }
            self.isUpdating = false
            self.tableView.isUserInteractionEnabled = true
            if permission == nil {
                self.permissions = previousPermissions
                self.writeAccess = previousWrite
                self.tableView.reloadData()
                self.showAlert(
                    title: "Error",
                    message: "Failed to update permissions."
                )
            } else {
                self.permissions = enforcedPermissions
            }
        }
    }
}

// MARK: Table View
extension FamilyMemberViewController: UITableViewDelegate, UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3  // Section 0: Allow Access To, Section 1: Shared With You
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)
        -> Int
    {
        if section == 0 {
            return accessOptions.count
        } else if section == 1 {
            return 1
        } else {
            return sharedOptionsList.count
        }
    }

    // MARK: Table View Header
    func tableView(
        _ tableView: UITableView,
        viewForHeaderInSection section: Int
    ) -> UIView? {

        // Create a container view
        let headerView = UIView()
        headerView.backgroundColor = .clear  // Keep transparent for Inset Grouped look

        // Create the Label
        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)  // Match your design
        titleLabel.textColor = .label  // Black/White
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        // Set text based on section
        if section == 0 {
            titleLabel.text = "Allow Access To"
        } else if section == 1 {
            titleLabel.text = "Special Permission"
        } else {
            titleLabel.text = "Shared With You"
        }

        headerView.addSubview(titleLabel)

        // Set Constraints to create the SPACING
        NSLayoutConstraint.activate([
            // Left margin (matches Inset Grouped look)
            titleLabel.leadingAnchor.constraint(
                equalTo: headerView.leadingAnchor,
                constant: 20
            ),

            // Top margin (Push text down a bit)
            titleLabel.topAnchor.constraint(
                equalTo: headerView.topAnchor,
                constant: 18
            ),

            // BOTTOM MARGIN (This is the space between Text and Cells)
            // A larger negative number = more space
            titleLabel.bottomAnchor.constraint(
                equalTo: headerView.bottomAnchor,
                constant: -16
            ),
        ])

        return headerView
    }

    // 2. Tell the table how tall this new custom header is
    func tableView(
        _ tableView: UITableView,
        heightForHeaderInSection section: Int
    ) -> CGFloat {
        return 50  // Adjust this if you want even more total space
    }

    func tableView(
        _ tableView: UITableView,
        willDisplayHeaderView view: UIView,
        forSection section: Int
    ) {
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.font = UIFont.systemFont(
                ofSize: 20,
                weight: .bold
            )
            header.textLabel?.textColor = .label
        }
    }

    // MARK: - Cell Configuration

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell
    {
        if indexPath.section == 0 {
            let cell =
                tableView.dequeueReusableCell(
                    withIdentifier: "switch_cell",
                    for: indexPath
                ) as! MemberSwitchTableViewCell
            cell.titleLabel.text = accessOptions[indexPath.row]
            cell.permissionSwitch.removeTarget(
                nil,
                action: nil,
                for: .allEvents
            )
            cell.permissionSwitch.tag = indexPath.row
            switch indexPath.row {
            case 0:
                cell.permissionSwitch.isOn = permissions.documents
            case 1:
                cell.permissionSwitch.isOn = permissions.meals
            case 2:
                cell.permissionSwitch.isOn = permissions.symptoms
            case 3:
                cell.permissionSwitch.isOn = permissions.glucose
            case 4:
                cell.permissionSwitch.isOn = permissions.water
            default:
                cell.permissionSwitch.isOn = false
            }
            cell.permissionSwitch.addTarget(
                self,
                action: #selector(permissionSwitchChanged(_:)),
                for: .valueChanged
            )
            cell.permissionSwitch.isEnabled = !isUpdating
            return cell

        } else if indexPath.section == 1 {
            // Reusing your existing switch cell for the new section!
            let cell =
                tableView.dequeueReusableCell(
                    withIdentifier: "switch_cell",
                    for: indexPath
                ) as! MemberSwitchTableViewCell
            cell.titleLabel.text = "Write Access"
            cell.permissionSwitch.removeTarget(
                nil,
                action: nil,
                for: .allEvents
            )
            cell.permissionSwitch.tag = 100
            cell.permissionSwitch.isOn = writeAccess
            cell.permissionSwitch.addTarget(
                self,
                action: #selector(permissionSwitchChanged(_:)),
                for: .valueChanged
            )
            cell.permissionSwitch.isEnabled = !isUpdating
            return cell

        } else {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "arrow_cell",
                for: indexPath
            )
            cell.textLabel?.text = sharedOptionsList[indexPath.row].title
            return cell
        }
    }

    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 2 {
            performSegue(
                withIdentifier: sharedOptionsList[indexPath.row].segue,
                sender: nil
            )
        }
    }

    func tableView(
        _ tableView: UITableView,
        willSelectRowAt indexPath: IndexPath
    ) -> IndexPath? {
        return indexPath.section == 2 ? indexPath : nil
    }
}
