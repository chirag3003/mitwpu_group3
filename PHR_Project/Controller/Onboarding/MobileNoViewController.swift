//
//  MobileNoViewController.swift
//  PHR_Project
//
//  Created by Sushant Pulipati on 03/02/26.
//

import UIKit

class MobileNoViewController: UIViewController {

    @IBOutlet weak var phoneNo: UITextField!
    
    override func viewDidLoad() {
            super.viewDidLoad()
            setupTextField()
        }
        
        private func setupTextField() {
            phoneNo.delegate = self
            phoneNo.keyboardType = .numberPad
        }

        // MARK: - Validation Function
        private func isPhoneNoValid() -> Bool {
            guard let text = phoneNo.text else { return false }
            
            // Check if length is exactly 10
            return text.count == 10
        }


    }

    // MARK: - UITextFieldDelegate
    extension MobileNoViewController: UITextFieldDelegate {
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            
            let currentText = textField.text ?? ""
            guard let stringRange = Range(range, in: currentText) else { return false }
            let updatedText = currentText.replacingCharacters(in: stringRange, with: string)

            let allowedCharacters = CharacterSet.decimalDigits
            let characterSet = CharacterSet(charactersIn: string)
            let isNumber = allowedCharacters.isSuperset(of: characterSet)

            return isNumber && updatedText.count <= 10
        }
    }
