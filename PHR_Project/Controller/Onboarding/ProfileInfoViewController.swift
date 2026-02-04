import UIKit

class ProfileInfoViewController: UIViewController {

    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    
    @IBOutlet weak var maleBtn: UIButton!
    @IBOutlet weak var femaleBtn: UIButton!
    @IBOutlet weak var otherBtn: UIButton!
    
    // MARK: - Properties
    private var selectedGender: String?
    private let selectedColor = UIColor(red: 74/255, green: 144/255, blue: 226/255, alpha: 1.0) // #4A90E2
    private let unselectedColor = UIColor(red: 189/255, green: 215/255, blue: 238/255, alpha: 1.0) // #BDD7EE
    
    // Array to store profile data as we collect it
    var profileDataArray: [String: Any] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGenderButtons()
        setupTextFields()
    }
    
    // MARK: - Setup
    private func setupGenderButtons() {
        let buttons = [maleBtn, femaleBtn, otherBtn]
        
        for button in buttons {
            guard let button = button else { continue }
//            
//            button.backgroundColor = unselectedColor
//            button.layer.cornerRadius = 10
//            button.layer.borderWidth = 0
//            button.setTitleColor(.black, for: .normal)
//            button.setTitleColor(.white, for: .selected)
//            
            button.addTarget(self, action: #selector(genderButtonTapped(_:)), for: .touchUpInside)
        }
    }
    
    private func setupTextFields() {
        firstName.delegate = self
        lastName.delegate = self
        
//        firstName.addLeftPadding(12)
//        lastName.addLeftPadding(12)
    }
    
    // MARK: - Actions
    @objc private func genderButtonTapped(_ sender: UIButton) {
        deselectAllGenderButtons()
        
        sender.isSelected = true
        sender.backgroundColor = selectedColor
//        sender.layer.borderWidth = 3
//        sender.layer.borderColor = UIColor(red: 44/255, green: 90/255, blue: 160/255, alpha: 1.0).cgColor
        
        switch sender {
        case maleBtn:
            selectedGender = "Male"
            print("Selected gender: Male")
        case femaleBtn:
            selectedGender = "Female"
            print("Selected gender: Female")
        case otherBtn:
            selectedGender = "Other"
            print("Selected gender: Other")
        default:
            break
        }
    }
    
    private func deselectAllGenderButtons() {
        let buttons = [maleBtn, femaleBtn, otherBtn]
        
        for button in buttons {
            guard let button = button else { continue }
            
            button.isSelected = false
            button.backgroundColor = unselectedColor
            button.layer.borderWidth = 0
        }
    }

    @IBAction func nextBtn(_ sender: Any) {
        if validateInputs() {
            saveDataToArray()
            printCurrentData()
            // Segue will happen automatically via storyboard
        }
    }
    
    // MARK: - Data Management
    private func saveDataToArray() {
        profileDataArray["firstName"] = firstName.text?.trimmingCharacters(in: .whitespaces)
        profileDataArray["lastName"] = lastName.text?.trimmingCharacters(in: .whitespaces)
        profileDataArray["sex"] = selectedGender
    }
    
    private func printCurrentData() {
        print("========== Profile Data ==========")
        print("First Name: \(profileDataArray["firstName"] ?? "")")
        print("Last Name: \(profileDataArray["lastName"] ?? "")")
        print("Gender: \(profileDataArray["sex"] ?? "")")
        print("==================================")
    }
    
    // MARK: - Validation
    private func validateInputs() -> Bool {
        guard let first = firstName.text, !first.trimmingCharacters(in: .whitespaces).isEmpty else {
            showAlert(title: "First Name Missing",message: "Please enter your first name")
            return false
        }
        
        guard let last = lastName.text, !last.trimmingCharacters(in: .whitespaces).isEmpty else {
            showAlert(title: "Last Name Missing",message: "Please enter your last name")
            return false
        }
        
        guard selectedGender != nil else {
            showAlert(title: "Gender not selected",message: "Please select your gender")
            return false
        }
        
        return true
    }
    
//    private func showAlert(message: String) {
//        let alert = UIAlertController(title: "Missing Information", message: message, preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "OK", style: .default))
//        present(alert, animated: true)
//    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Pass the data array to the next screen
        // Example for DOB screen:
        if let dobVC = segue.destination as? DobViewController {
            dobVC.profileDataArray = profileDataArray
        }
    }
}

// MARK: - UITextFieldDelegate
extension ProfileInfoViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == firstName {
            lastName.becomeFirstResponder()
        } else if textField == lastName {
            lastName.resignFirstResponder()
        }
        return true
    }
}

//// MARK: - UITextField Extension
//extension UITextField {
//    func addLeftPadding(_ padding: CGFloat) {
//        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: padding, height: self.frame.height))
//        self.leftView = paddingView
//        self.leftViewMode = .always
//    }
//}
