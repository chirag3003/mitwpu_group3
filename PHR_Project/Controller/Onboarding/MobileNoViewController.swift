//
//  MobileNoViewController.swift
//  PHR_Project
//
//  Created by Sushant Pulipati on 03/02/26.
//

import UIKit

class MobileNoViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var numberField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

      setupTextFields()
    }
    

    private func setupTextFields() {
        numberField.delegate = self
        
        // Custom Function to round text fields
        styleTextField(numberField)
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
