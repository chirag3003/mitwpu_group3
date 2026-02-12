//
//  MobileNoViewController.swift
//  PHR_Project
//
//  Created by Sushant Pulipati on 03/02/26.
//

import UIKit

class MobileNoViewController: UIViewController, UITextFieldDelegate {
<<<<<<< HEAD
<<<<<<< HEAD
=======
>>>>>>> 66c1cb9be88eb27cfd6c26e60d9a4b5bb3e092ad
    
    @IBOutlet weak var numberField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        //  setupTextField()
    }
    
    //        private func setupTextField() {
    //            phoneNo.delegate = self
    //            phoneNo.keyboardType = .numberPad
    //        }
    //
    //      setupTextFields()
    //    }
    //
    //
    //    private func setupTextFields() {
    //        numberField.delegate = self
    //
    //        // Custom Function to round text fields
    //        styleTextField(numberField)
    //    }
    //
    //    private func styleTextField(_ textField: UITextField) {
    //        // This manually forces the rounding
    //        textField.layer.cornerRadius = 16
    //        textField.layer.masksToBounds = true
    //
    //
    //        textField.layer.borderWidth = 1.0
    //        textField.layer.borderColor = UIColor.systemGray5.cgColor
    //
    //
    //        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: textField.frame.height))
    //        textField.leftView = paddingView
    //        textField.leftViewMode = .always
    //    }
    //
    //    /*
    //    // MARK: - Navigation
    //
    //    }
    //
    //    // MARK: - UITextFieldDelegate
    //    extension MobileNoViewController: UITextFieldDelegate {
    //        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    //
    //            let currentText = textField.text ?? ""
    //            guard let stringRange = Range(range, in: currentText) else { return false }
    //            let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
    //
    //            let allowedCharacters = CharacterSet.decimalDigits
    //            let characterSet = CharacterSet(charactersIn: string)
    //            let isNumber = allowedCharacters.isSuperset(of: characterSet)
    //
    //            return isNumber && updatedText.count <= 10
    //        }
    //    }
}
<<<<<<< HEAD
=======

//    @IBOutlet weak var numberField: UITextField!
//    override func viewDidLoad() {
//            super.viewDidLoad()
//            setupTextField()
//        }
//        
//        private func setupTextField() {
//            phoneNo.delegate = self
//            phoneNo.keyboardType = .numberPad
//        }
//
//      setupTextFields()
    }
    

//    private func setupTextFields() {
//        numberField.delegate = self
//        
//        // Custom Function to round text fields
//        styleTextField(numberField)
//    }
//    
//    private func styleTextField(_ textField: UITextField) {
//        // This manually forces the rounding
//        textField.layer.cornerRadius = 16
//        textField.layer.masksToBounds = true
//        
//       
//        textField.layer.borderWidth = 1.0
//        textField.layer.borderColor = UIColor.systemGray5.cgColor
//        
//       
//        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: textField.frame.height))
//        textField.leftView = paddingView
//        textField.leftViewMode = .always
//    }
//    
//   
//}
>>>>>>> 142515bda2737dad0524549d37f191e4ec93fab2
=======
>>>>>>> 66c1cb9be88eb27cfd6c26e60d9a4b5bb3e092ad
