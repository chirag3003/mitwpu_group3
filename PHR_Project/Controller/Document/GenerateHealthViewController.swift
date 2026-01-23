//
//  GenerateHealthViewController.swift
//  PHR_Project
//
//  Created by SDC-USER on 28/11/25.
//

import UIKit

class GenerateHealthViewController: UIViewController {

    // MARK: - Outlets

    @IBOutlet weak var scrollView: UIScrollView!
    //Container Views
    @IBOutlet weak var dateInputView: UIView!
    @IBOutlet weak var TypeOfVisitView: UIView!
    @IBOutlet weak var DataFields: UIView!
    @IBOutlet weak var AdditionalNotes: UIView!

    //Input Controls
    @IBOutlet weak var fromDatePicker: UIDatePicker!
    @IBOutlet weak var notesTextField: UITextField!
    @IBOutlet weak var TextField: UITextField!
   

    // MARK: - Lifecycle

    override func viewDidLoad() {

        super.viewDidLoad()
        // Add rounded corners to container views
        dateInputView.addRoundedCorner()
        TypeOfVisitView.addRoundedCorner()
        DataFields.addRoundedCorner()
        AdditionalNotes.addRoundedCorner()
        
        // Dismiss keyboard on background tap
        setupHideKeyboardOnTap()
        
        // Style notes text field
        notesTextField.addRoundedCorner(radius: 8)
        notesTextField.borderStyle = .none
        
        // Style standard text field
        TextField.borderStyle = .none
        TextField.layer.cornerRadius = 8.0
        TextField.layer.masksToBounds = true
        
        // Add left padding to standard text field
        let paddingView = UIView(
            frame: CGRect(x: 0, y: 0, width: 10, height: TextField.frame.height)
        )
        TextField.leftView = paddingView
        TextField.leftViewMode = .always

        // Add horizontal padding to notes text field
        let notesLeftPadding = UIView(
            frame: CGRect(
                x: 0,
                y: 0,
                width: 12,
                height: notesTextField.frame.height
            )
        )
        let notesRightPadding = UIView(
            frame: CGRect(
                x: 0,
                y: 0,
                width: 12,
                height: notesTextField.frame.height
            )
        )
        notesTextField.leftView = notesLeftPadding
        notesTextField.leftViewMode = .always
        notesTextField.rightView = notesRightPadding
        notesTextField.rightViewMode = .always
        // Align text to top with vertical padding
        notesTextField.contentVerticalAlignment = .top
        
        notesTextField.layer.sublayerTransform = CATransform3DMakeTranslation(
            0,
            6,
            0
        )
        // Register for keyboard notifications
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    // MARK: - Keyboard Handling

    @objc func keyboardWillShow(notification: NSNotification) {
        //  Get keyboard height
        guard
            let keyboardSize =
                (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey]
                as? NSValue)?.cgRectValue
        else { return }

        //  Adjust scroll view bottom inset to account for keyboard
        let contentInsets = UIEdgeInsets(
            top: 0.0,
            left: 0.0,
            bottom: keyboardSize.height,
            right: 0.0
        )
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        // Reset scroll view insets when keyboard dismisses
        let contentInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }

    // MARK: - Cleanup

    deinit {
        //Remove keyboard observers
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Helpers

    func setupHideKeyboardOnTap() {
        //Add tap gesture to dismiss keyboard
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(handleBackgroundTap)
        )
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func handleBackgroundTap() {
        view.endEditing(true)
    }

    // MARK: - Actions

    @IBAction func toggleSelection(_ sender: UISwitch) {
        sender.isSelected.toggle()
    }

}
