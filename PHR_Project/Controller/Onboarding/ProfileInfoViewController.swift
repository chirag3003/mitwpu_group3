import UIKit

class ProfileInfoViewController: UIViewController {

    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    
    @IBOutlet weak var maleBtn: UIButton!
    @IBOutlet weak var femaleBtn: UIButton!
    @IBOutlet weak var otherBtn: UIButton!
    
    // MARK: - Properties
        private var selectedGender: String?
        
        // Adjusted colors slightly for better visibility
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
                
                // Force rounded corners (Capsule style)
                button.layer.cornerRadius = 15 // Adjust this value to make it more/less round
                button.clipsToBounds = true
                
                // Set initial color using the helper
                setButtonColor(button, color: unselectedColor)
                
                // Set Text Colors
                button.setTitleColor(.black, for: .normal)
                button.setTitleColor(.white, for: .selected)
                
                button.addTarget(self, action: #selector(genderButtonTapped(_:)), for: .touchUpInside)
            }
        }
        
        private func setupTextFields() {
            firstName.delegate = self
            lastName.delegate = self
            
            // Custom Function to round text fields
            styleTextField(firstName)
            styleTextField(lastName)
        }
        
        private func styleTextField(_ textField: UITextField) {
            // This manually forces the rounding
            textField.layer.cornerRadius = 16
            textField.layer.masksToBounds = true
            
           
            textField.layer.borderWidth = 1.0
            textField.layer.borderColor = UIColor.systemGray5.cgColor
            
           
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: textField.frame.height))
            textField.leftView = paddingView
            textField.leftViewMode = .always
        }
        
        // MARK: - Helper for Button Colors (Fixes the issue)
        private func setButtonColor(_ button: UIButton, color: UIColor) {
        
            if button.configuration != nil {
                button.configuration?.baseBackgroundColor = color
            } else {
                // Fallback for older style buttons
                button.backgroundColor = color
            }
        }
        
        // MARK: - Actions
    @objc private func genderButtonTapped(_ sender: UIButton) {
            
            // Reset ALL buttons to unselected
            let allButtons = [maleBtn, femaleBtn, otherBtn]
            for btn in allButtons {
                updateButtonAppearance(btn!, isSelected: false)
            }
            
            // Set the TAPPED button to selected
            updateButtonAppearance(sender, isSelected: true)

            switch sender {
            case maleBtn:
                selectedGender = "Male"
            case femaleBtn:
                selectedGender = "Female"
            case otherBtn:
                selectedGender = "Other"
            default:
                break
            }
            print("Selected gender: \(selectedGender ?? "None")")
        }
    
    private func updateButtonAppearance(_ button: UIButton, isSelected: Bool) {
            
            let colorToUse = isSelected ? selectedColor : unselectedColor
            let textColorToUse: UIColor = isSelected ? .white : .black
            
            // Set Text Color
            button.setTitleColor(textColorToUse, for: .normal)
            
            // Set Background Color (Handles both Modern and Legacy buttons)
            if button.configuration != nil {
                button.configuration?.baseBackgroundColor = colorToUse
            } else {
                button.backgroundColor = colorToUse
            }
        }
        
        
        private func deselectAllGenderButtons() {
            let buttons = [maleBtn, femaleBtn, otherBtn]
            
            for button in buttons {
                guard let button = button else { continue }
                
                button.isSelected = false
                
                // Reset color using the helper
                setButtonColor(button, color: unselectedColor)
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
                presentAlert(title: "First Name Missing", message: "Please enter your first name")
                return false
            }
            
            guard let last = lastName.text, !last.trimmingCharacters(in: .whitespaces).isEmpty else {
                presentAlert(title: "Last Name Missing", message: "Please enter your last name")
                return false
            }
            
            guard selectedGender != nil else {
                presentAlert(title: "Gender not selected", message: "Please select your gender")
                return false
            }
            
            return true
        }
        
        // MARK: - Helper for Alerts
         func presentAlert(title: String, message: String) {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
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

