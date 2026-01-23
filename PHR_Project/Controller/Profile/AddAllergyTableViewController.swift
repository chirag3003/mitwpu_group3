import UIKit

class AddAllergyTableViewController: UITableViewController {

    // MARK: - Outlets
    @IBOutlet weak var allergyIngredient: UITextField!
    @IBOutlet weak var allergyDetailReaction: UITextField!
    @IBOutlet weak var intensityButton: UIButton!

    // Keep reference to fields for keyboard management if needed
    var allTextFields: [UITextField] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup Data Arrays
        allTextFields = [allergyIngredient, allergyDetailReaction]

        // Setup UI
        setupPullDownButton()

        self.addKeyboardDisapperanceGesture()

        removeBorder(from: allergyIngredient)
        removeBorder(from: allergyDetailReaction)
    }

    // MARK: - Setup Logic
    func setupPullDownButton() {
        let optionClosure: UIActionHandler = { action in
            print("User selected intensity: \(action.title)")
        }

        // Define options
        let option1 = UIAction(title: "Low", handler: optionClosure)
        // We keep Moderate as the default selection for the BUTTON so it's not empty
        let option2 = UIAction(
            title: "Moderate",
            state: .on,
            handler: optionClosure
        )
        let option3 = UIAction(title: "High", handler: optionClosure)

        // Configure Menu
        let menu = UIMenu(children: [option1, option2, option3])

        intensityButton.menu = menu
        intensityButton.showsMenuAsPrimaryAction = true
        intensityButton.changesSelectionAsPrimaryAction = true
    }

    // MARK: - Actions

    // Connect this to your 'Done' or 'Save' bar button item
    @IBAction func saveTapped(_ sender: UIBarButtonItem) {

        // 1. Validate Ingredient Name
        // We use guard to ensure the user actually wrote something
        guard let name = allergyIngredient.text, !name.isEmpty else {
            self.showAlert(title: "Missing Info", message: "Please enter the allergy ingredient.")
            return
        }

        // 2. Gather Data
        let reaction = allergyDetailReaction.text ?? ""
        let intensity = intensityButton.currentTitle ?? "Moderate"

        // 3. Show Loader
        showLoader(true)

        // 4. Call Service
        let newAllergy = Allergy(
            id: UUID(),
            name: name,
            severity: intensity,
            notes: reaction
        )

        AllergyService.shared.addAllergy(newAllergy) { [weak self] result in
            guard let self = self else { return }

            DispatchQueue.main.async {
                self.showLoader(false)

                switch result {
                case .success:
                    // Dismiss on success
                    self.navigationController?.popViewController(animated: true)

                case .failure(let error):
                    // Show Error
                    self.showAlert(
                        title: "Error",
                        message:
                            "Failed to add allergy: \(error.localizedDescription)"
                    )
                }
            }
        }
    }

    @IBAction func allergyIngredient(_ sender: UITextField) {}
    @IBAction func allergyDetailReaction(_ sender: Any) {}
    @IBAction func intensityButton(_ sender: UIButton) {}



    // MARK: - Table View Overrides

    // Returns .none to ensure no delete/edit UI ever appears
    override func tableView(
        _ tableView: UITableView,
        editingStyleForRowAt indexPath: IndexPath
    )
        -> UITableViewCell.EditingStyle
    {
        return .none
    }

    override func tableView(
        _ tableView: UITableView,
        shouldIndentWhileEditingRowAt indexPath: IndexPath
    ) -> Bool {
        return false
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

}
