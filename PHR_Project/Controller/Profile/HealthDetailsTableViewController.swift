import Foundation
import UIKit

class HealthDetailsTableViewController: UITableViewController,
    UITextFieldDelegate
{

    // MARK: - Outlets

    // Text Fields
    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var heightTextField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var firstNameField: UITextField!

    // Buttons & Date Picker
    @IBOutlet weak var healthProfileImage: UIImageView!
    @IBOutlet weak var sexSelectButton: UIButton!
    @IBOutlet weak var bloodTypeButton: UIButton!
    @IBOutlet weak var typeSelectButton: UIButton!
    @IBOutlet weak var dobInput: UIDatePicker!

    var allTextFields: [UITextField] = []
    var allButtons: [UIButton] = []

    var profileData: ProfileModel?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        profileData = ProfileService.shared.getProfile()

        weightTextField.delegate = self
        heightTextField.delegate = self

        // Also, force the keyboard style here just in case Storyboard failed
        weightTextField.keyboardType = .decimalPad
        heightTextField.keyboardType = .decimalPad

        healthProfileImage.addFullRoundedCorner()

        // This adds the system "Edit" button which automatically toggles "Done"
        self.navigationItem.rightBarButtonItem = self.editButtonItem

        allTextFields = [
            firstNameField, lastNameField, heightTextField, weightTextField,
        ]
        allButtons = [sexSelectButton, bloodTypeButton, typeSelectButton]

        updateTextFieldsState(isEditing: false)

        setupFields()

    }

    private func setupFields() {
        firstNameField.text = profileData?.firstName
        lastNameField.text = profileData?.lastName
        heightTextField.text = "\(profileData?.height ?? 0)"
        weightTextField.text = "\(profileData?.weight ?? 0)"
        dobInput.date = profileData?.dob ?? Foundation.Date()
        setupPullDownButton()
        setupTypeSelectButton()
        setupBloodSelectButton()
    }

    // MARK: - Actions

    @IBAction func typeSelectButton(_ sender: UIButton) {
    }

    @IBAction func sexSelectButton(_ sender: UIButton) {
    }

    @IBAction func bloodTypeButton(_ sender: UIButton) {
    }

    func setupPullDownButton() {

        let optionClosure: UIActionHandler = { [weak self] action in

            _ = self  // keep self captured if needed later
        }

        let sexOptions = ["Male", "Female", "Other"]

        let options: [UIAction] = sexOptions.map { title in

            // Determine the state: if the title matches profileData.sex, set state to .on, otherwise .off
            let currentState: UIMenuElement.State =
                (title == profileData!.sex) ? .on : .off

            // UIAction with the dynamically determined state
            let action = UIAction(
                title: title,
                state: currentState,
                handler: optionClosure
            )
            return action
        }

        let menu = UIMenu(children: options)

        // Configure the Button (use the outlet UIButton)
        sexSelectButton.menu = menu
        sexSelectButton.showsMenuAsPrimaryAction = true
        sexSelectButton.changesSelectionAsPrimaryAction = true
    }

    func setupBloodSelectButton() {
        let selectionClosure = { (action: UIAction) in
            print("Blood Type Selected: \(action.title)")
        }
        let allBloodTypes = ["A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"]

        let actions: [UIAction] = allBloodTypes.map { bloodTypeTitle in

            // Determine the state: if the title matches profileData.bloodType, set state to .on
            let currentState: UIMenuElement.State =
                (bloodTypeTitle == profileData!.bloodType) ? .on : .off

            // =Create the UIAction with the dynamically determined state
            let action = UIAction(
                title: bloodTypeTitle,
                state: currentState,
                handler: selectionClosure
            )
            return action
        }
        let menu = UIMenu(children: actions)

        bloodTypeButton.menu = menu
        bloodTypeButton.showsMenuAsPrimaryAction = true
        bloodTypeButton.changesSelectionAsPrimaryAction = true
    }

    // MARK: - Diabetes Type Setup

    func setupTypeSelectButton() {
        let selectionClosure = { (action: UIAction) in
            print("Diabetes Type Selected: \(action.title)")
        }
        let allDiabetesTypes = [
            "Type 1", "Type 2", "Gestational", "Prediabetes",
        ]

        let actions: [UIAction] = allDiabetesTypes.map { typeTitle in

            // Determine the state: if the title matches profileData.diabetesType, set state to .on
            let currentState: UIMenuElement.State =
                (typeTitle == profileData!.diabetesType) ? .on : .off

            // Create the UIAction with the dynamically determined state
            let action = UIAction(
                title: typeTitle,
                state: currentState,
                handler: selectionClosure
            )
            return action
        }

        // Menu using the dynamically generated actions
        let menu = UIMenu(children: actions)
        typeSelectButton.menu = menu
        typeSelectButton.showsMenuAsPrimaryAction = true
        typeSelectButton.changesSelectionAsPrimaryAction = true
    }

    override func setEditing(_ editing: Bool, animated: Bool) {

        if editing {

            if heightTextField.text == "Not Set" {
                heightTextField.text = ""
            }
            if weightTextField.text == "Not Set" {
                weightTextField.text = ""
            }
        }

        if !editing {

            // Get current text values
            let fName =
                firstNameField.text?.trimmingCharacters(
                    in: .whitespacesAndNewlines
                ) ?? ""
            let lName =
                lastNameField.text?.trimmingCharacters(
                    in: .whitespacesAndNewlines
                ) ?? ""

            // Check if Names are empty
            if fName.isEmpty || lName.isEmpty {
                showAlert(message: "First and last name cannot be empty.")

                // Prevent exiting edit mode
                super.setEditing(true, animated: false)
                return
            }

            // If empty, set them back to "Not Set"
            if heightTextField.text?.trimmingCharacters(
                in: .whitespacesAndNewlines
            ).isEmpty ?? true {
                heightTextField.text = "Not Set"
            }

            if weightTextField.text?.trimmingCharacters(
                in: .whitespacesAndNewlines
            ).isEmpty ?? true {
                weightTextField.text = "Not Set"
            }

            // 4. Save Logic
            saveData()
        }

        // Toggle the mode
        super.setEditing(editing, animated: animated)
        updateTextFieldsState(isEditing: editing)
    }

    func updateTextFieldsState(isEditing: Bool) {

        // Text Fields
        for field in allTextFields {
            field.isUserInteractionEnabled = isEditing
            field.borderStyle = isEditing ? .roundedRect : .none
            field.textColor = isEditing ? .systemBlue : .label
        }

        // Buttons
        for button in allButtons {
            button.isUserInteractionEnabled = isEditing
            button.tintColor = isEditing ? .systemBlue : .label
        }

        // Use this property to freeze DatePicker without greying it out
        dobInput.isUserInteractionEnabled = isEditing

        dobInput.alpha = 1.0

        if isEditing {
            firstNameField.becomeFirstResponder()
        } else {
            view.endEditing(true)
        }
    }

    func saveData() {

        print("Saving Data...")

        let profile = ProfileModel(
            firstName: firstNameField.text ?? "",
            lastName: lastNameField.text ?? "",
            dob: dobInput.date,
            sex: sexSelectButton.titleLabel?.text ?? "",
            diabetesType: typeSelectButton.titleLabel?.text ?? "",
            bloodType: bloodTypeButton.titleLabel?.text ?? "",
            height: Int(heightTextField?.text ?? "") ?? 0,
            weight: Int(weightTextField?.text ?? "") ?? 0
        )

        ProfileService.shared.setProfile(to: profile)

    }

    // MARK: - Disable Delete Functionality

    // MARK: - Prevent Default Editing UI

    // This prevents the red "minus" delete button from appearing
    override func tableView(
        _ tableView: UITableView,
        editingStyleForRowAt indexPath: IndexPath
    ) -> UITableViewCell.EditingStyle {
        return .none
    }

    // This prevents the row from sliding to the right
    override func tableView(
        _ tableView: UITableView,
        shouldIndentWhileEditingRowAt indexPath: IndexPath
    ) -> Bool {
        return false
    }

    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {

        // Check if this is one of our number fields
        if textField == weightTextField || textField == heightTextField {

            // Allow backspace (string is empty when deleting)
            if string.isEmpty { return true }

            // Define what is allowed
            let allowedCharacters = CharacterSet(charactersIn: "0123456789.")
            let characterSet = CharacterSet(charactersIn: string)

            // Check if the typed char is valid
            let isNumber = allowedCharacters.isSuperset(of: characterSet)

            if isNumber {

                // Prevent multiple dots (e.g. 12.5.5)
                let currentText = textField.text ?? ""
                if string == "." && currentText.contains(".") {
                    return false  // Reject the second dot
                }
                return true
            } else {
                return false
            }
        }

        return true
    }

    //Custom section headers

    override func tableView(
        _ tableView: UITableView,
        viewForHeaderInSection section: Int
    ) -> UIView? {

        // Create a container view
        let headerView = UIView()
        headerView.backgroundColor = .clear

        // Create the label
        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)  // Larger and Bolder
        titleLabel.textColor = .label  // Standard Black (or White in Dark Mode)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        // Set the text based on the section index
        switch section {
        case 0:
            titleLabel.text = "User Details"
        case 1:
            titleLabel.text = "Health Information"
        case 2:
            titleLabel.text = "Additional Details"
        default:
            return nil
        }

        // Add label to the container
        headerView.addSubview(titleLabel)

        NSLayoutConstraint.activate([

            titleLabel.leadingAnchor.constraint(
                equalTo: headerView.leadingAnchor,
                constant: 20
            ),

            titleLabel.bottomAnchor.constraint(
                equalTo: headerView.bottomAnchor,
                constant: -12
            ),

            titleLabel.topAnchor.constraint(
                equalTo: headerView.topAnchor,
                constant: 15
            ),
        ])

        return headerView
    }

    // Define the height

    override func tableView(
        _ tableView: UITableView,
        heightForHeaderInSection section: Int
    ) -> CGFloat {
        // Return a height large enough
        return 60
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // This ensures the style is applied after the layout is finished
        removeBorder(from: firstNameField)
        removeBorder(from: lastNameField)
        removeBorder(from: heightTextField)
        removeBorder(from: weightTextField)
    }

    func removeBorder(from textField: UITextField) {
        textField.borderStyle = .none
        textField.backgroundColor = .clear

        // Force the layer to be clean
        textField.layer.borderWidth = 0
        textField.layer.borderColor = UIColor.clear.cgColor

        // Disable the Focus Ring (Blue glow)
        if #available(iOS 15.0, *) {
            textField.focusEffect = nil
        }
    }

    // MARK: - Helper for Alerts
    func showAlert(message: String) {
        let alert = UIAlertController(
            title: "Missing Information",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(
            UIAlertAction(title: "Ok", style: .default, handler: nil)
        )
        present(alert, animated: true, completion: nil)
    }

}
