//
//  HealthDetailsTableViewController.swift
//  PHR_Project
//
//  Created by SDC_USER on 26/11/25.
//
import Foundation
import UIKit

class HealthDetailsTableViewController: UITableViewController,
    UITextFieldDelegate
{

    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var heightTextField: UITextField!
    @IBOutlet weak var dobInput: UIDatePicker!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var healthProfileImage: UIImageView!
    @IBOutlet weak var sexSelectButton: UIButton!
    @IBOutlet weak var bloodTypeButton: UIButton!
    @IBOutlet weak var typeSelectButton: UIButton!

    // Group them for easier toggling
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

        // 1. UI Setup
        healthProfileImage.addFullRoundedCorner()

        // 2. Setup Edit Button
        // This adds the system "Edit" button which automatically toggles "Done"
        self.navigationItem.rightBarButtonItem = self.editButtonItem

        // 3. Store fields in array for easy management
        // (Make sure to add all your outlets here)
        allTextFields = [
            firstNameField, lastNameField, heightTextField, weightTextField,
        ]
        allButtons = [sexSelectButton, bloodTypeButton, typeSelectButton]
        // 4. Ensure styling is correct (Look like labels initially)
        updateTextFieldsState(isEditing: false)

        // 5. Configure the fields
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

    @IBAction func typeSelectButton(_ sender: UIButton) {
        // Configure another similar menu if needed
    }

    @IBAction func sexSelectButton(_ sender: UIButton) {
        // IBAction can remain empty when using showsMenuAsPrimaryAction
        // The menu is presented automatically on tap.
    }

    @IBAction func bloodTypeButton(_ sender: UIButton) {
    }

    func setupPullDownButton() {
        // 1. Create the UIActions (The menu items)
        let optionClosure: UIActionHandler = { [weak self] action in
            // Update button title automatically handled by changesSelectionAsPrimaryAction
            // You can still react here if you need to persist the selection
            // print("Selected: \(action.title)")
            _ = self  // keep self captured if needed later
        }

        // Assuming optionClosure is defined and profileData.sex holds the current selection (e.g., "Male", "Female", or "Other")

        let sexOptions = ["Male", "Female", "Other"]

        let options: [UIAction] = sexOptions.map { title in
            // Determine the state: if the title matches profileData.sex, set state to .on, otherwise .off
            let currentState: UIMenuElement.State =
                (title == profileData!.sex) ? .on : .off

            // Create the UIAction with the dynamically determined state
            let action = UIAction(
                title: title,
                state: currentState,
                handler: optionClosure
            )
            return action
        }

        // Now the 'options' array contains three UIAction objects,
        // and only the one matching profileData.sex has state: .on
        // 2. Create the Menu
        let menu = UIMenu(children: options)

        // 3. Configure the Button (use the outlet UIButton)
        sexSelectButton.menu = menu
        sexSelectButton.showsMenuAsPrimaryAction = true
        sexSelectButton.changesSelectionAsPrimaryAction = true
    }

    func setupBloodSelectButton() {
        let selectionClosure = { (action: UIAction) in
            print("Blood Type Selected: \(action.title)")
        }
        let allBloodTypes = ["A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"]

        // 1. Map the array of strings into an array of UIAction objects
        let actions: [UIAction] = allBloodTypes.map { bloodTypeTitle in

            // 2. Determine the state: if the title matches profileData.bloodType, set state to .on
            let currentState: UIMenuElement.State =
                (bloodTypeTitle == profileData!.bloodType) ? .on : .off

            // 3. Create the UIAction with the dynamically determined state
            let action = UIAction(
                title: bloodTypeTitle,
                state: currentState,  // Dynamically set to .on or .off
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

        // 1. Map the array of strings into an array of UIAction objects
        let actions: [UIAction] = allDiabetesTypes.map { typeTitle in

            // 2. Determine the state: if the title matches profileData.diabetesType, set state to .on
            let currentState: UIMenuElement.State =
                (typeTitle == profileData!.diabetesType) ? .on : .off

            // 3. Create the UIAction with the dynamically determined state
            let action = UIAction(
                title: typeTitle,
                state: currentState,  // Dynamically set to .on or .off
                handler: selectionClosure
            )
            return action
        }

        // 4. Create the menu using the dynamically generated actions
        let menu = UIMenu(children: actions)
        typeSelectButton.menu = menu
        typeSelectButton.showsMenuAsPrimaryAction = true
        typeSelectButton.changesSelectionAsPrimaryAction = true
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)

        // Toggle the state of the text fields
        updateTextFieldsState(isEditing: editing)

        if !editing {
            saveData()  // Call save when user taps "Done"
        }
    }

    func updateTextFieldsState(isEditing: Bool) {
        for field in allTextFields {
            // Enable interaction only when editing
            field.isUserInteractionEnabled = isEditing

            // Visual feedback: Show border when editing, hide when not
            field.borderStyle = isEditing ? .roundedRect : .none

            // Optional: Change text color to indicate state
            field.textColor = isEditing ? .systemBlue : .label
        }

        for button in allButtons {
            button.isUserInteractionEnabled = isEditing
            button.tintColor = isEditing ? .systemBlue : .label
        }
        // If editing started, focus on the first field
        if isEditing {
            firstNameField.becomeFirstResponder()
        } else {
            view.endEditing(true)  // Hide keyboard
        }
    }

    func saveData() {
        print("Saving Data...")
        // Here you would save the text from textFields to your Data Model or UserDefaults
        // Example:
        // let newName = firstNameField.text
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

    // 1. This prevents the red "minus" delete button from appearing
    override func tableView(
        _ tableView: UITableView,
        editingStyleForRowAt indexPath: IndexPath
    ) -> UITableViewCell.EditingStyle {
        return .none
    }

    // 2. This prevents the row from sliding to the right (indenting)
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

        // 1. Check if this is one of your number fields
        if textField == weightTextField || textField == heightTextField {

            // Allow backspace (string is empty when deleting)
            if string.isEmpty { return true }

            // 2. Define what is allowed (Numbers 0-9 and one Decimal Point)
            let allowedCharacters = CharacterSet(charactersIn: "0123456789.")
            let characterSet = CharacterSet(charactersIn: string)

            // 3. Check if the typed char is valid
            let isNumber = allowedCharacters.isSuperset(of: characterSet)

            if isNumber {
                // 4. Special Rule: Prevent multiple dots (e.g. 12.5.5)
                let currentText = textField.text ?? ""
                if string == "." && currentText.contains(".") {
                    return false  // Reject the second dot
                }
                return true
            } else {
                return false  // Reject letters/symbols
            }
        }

        return true  // Allow everything for Name/Address fields
    }

}
