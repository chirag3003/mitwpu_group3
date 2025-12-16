//
//  GenerateHealthViewController.swift
//  PHR_Project
//
//  Created by SDC-USER on 28/11/25.
//

import UIKit
class GenerateHealthViewController: UIViewController {
    
    
    @IBOutlet weak var dateInputView: UIView!
    @IBOutlet weak var TypeOfVisitView: UIView!
    
    @IBOutlet weak var DataFields: UIView!
    @IBOutlet weak var fromDatePicker: UIDatePicker!
    
   
    
    @IBOutlet weak var TextField: UITextField!
    @IBOutlet weak var AdditionalNotes: UIView!
    override func viewDidLoad() {
    
        super.viewDidLoad()
        dateInputView.addRoundedCorner()
        TypeOfVisitView.addRoundedCorner()
        DataFields.addRoundedCorner()
        AdditionalNotes.addRoundedCorner()
        setupHideKeyboardOnTap()
        TextField.borderStyle = .none
                
                
                TextField.layer.cornerRadius = 8.0
                TextField.layer.borderWidth = 1.0
                TextField.layer.borderColor = UIColor.lightGray.cgColor
                TextField.layer.masksToBounds = true
                
                
                let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: TextField.frame.height))
                TextField.leftView = paddingView
                TextField.leftViewMode = .always
        setupHideKeyboardOnTap()
    }
    @objc func keyboardWillShow(notification: NSNotification) {
           
            if TextField.isFirstResponder {
                if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                    
                    if self.view.frame.origin.y == 0 {
                        self.view.frame.origin.y -= keyboardSize.height
                    }
                }
            }
        }

        @objc func keyboardWillHide(notification: NSNotification) {
            
            if self.view.frame.origin.y != 0 {
                self.view.frame.origin.y = 0
            }
        }
        
        
        deinit {
            NotificationCenter.default.removeObserver(self)
        }
    
    func setupHideKeyboardOnTap() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleBackgroundTap))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc private func handleBackgroundTap() {
        view.endEditing(true)
    }

    @IBAction func toggleSelection(_ sender: UISwitch) {
        sender.isSelected.toggle()
        if sender.isSelected {
                print("Button turned ON")
            } else {
                print("Button turned OFF")
            }
    }
    
    

    

}

