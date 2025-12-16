//
//  GenerateHealthViewController.swift
//  PHR_Project
//
//  Created by SDC-USER on 28/11/25.
//

import UIKit
class GenerateHealthViewController: UIViewController {
    
    
    @IBOutlet weak var scrollView: UIScrollView!
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
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
                NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
            
    }
    @objc func keyboardWillShow(notification: NSNotification) {
            // 1. Get the size of the keyboard
            guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }

            // 2. Add "Padding" to the bottom of the scroll view equal to the keyboard height
            let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize.height, right: 0.0)
            scrollView.contentInset = contentInsets
            scrollView.scrollIndicatorInsets = contentInsets
        }

        @objc func keyboardWillHide(notification: NSNotification) {
            // 1. Reset the padding to zero when keyboard disappears
            let contentInsets = UIEdgeInsets.zero
            scrollView.contentInset = contentInsets
            scrollView.scrollIndicatorInsets = contentInsets
        }

        // --- CLEANUP ---
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

