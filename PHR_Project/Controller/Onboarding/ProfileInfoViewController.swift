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
            
            //setting initial color
            button.backgroundColor = unselectedColor
            button.setTitleColor(.black, for: .normal)
            button.setTitleColor(.white, for: .selected)
            
            button.addTarget(self, action: #selector(genderButtonTapped(_:)), for: .touchUpInside)
        }
    }
    
    private func setupTextFields() {
        firstName.delegate = self
        lastName.delegate = self
    }
    
    // MARK: - Actions
    @objc private func genderButtonTapped(_ sender: UIButton) {
        deselectAllGenderButtons()
        
        sender.isSelected = true
        sender.backgroundColor = selectedColor

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

    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
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


