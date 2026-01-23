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
    @IBOutlet weak var dateInputView: UIView!
    @IBOutlet weak var TypeOfVisitView: UIView!

    @IBOutlet weak var DataFields: UIView!
    @IBOutlet weak var fromDatePicker: UIDatePicker!

    @IBOutlet weak var notesTextField: UITextField!
    @IBOutlet weak var TextField: UITextField!
    @IBOutlet weak var AdditionalNotes: UIView!

    // MARK: - Lifecycle

    override func viewDidLoad() {

        super.viewDidLoad()

        dateInputView.addRoundedCorner()
        TypeOfVisitView.addRoundedCorner()
        DataFields.addRoundedCorner()
        AdditionalNotes.addRoundedCorner()

        setupHideKeyboardOnTap()

        notesTextField.addRoundedCorner(radius: 8)
        notesTextField.borderStyle = .none
        TextField.borderStyle = .none
        TextField.layer.cornerRadius = 8.0
        TextField.layer.masksToBounds = true

        let paddingView = UIView(
            frame: CGRect(x: 0, y: 0, width: 10, height: TextField.frame.height)
        )
        TextField.leftView = paddingView
        TextField.leftViewMode = .always

        // Add padding for UITextField
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
        notesTextField.contentVerticalAlignment = .top
        // Nudge text down a bit to simulate top padding in UITextField
        notesTextField.layer.sublayerTransform = CATransform3DMakeTranslation(
            0,
            6,
            0
        )

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
        // 1. Get the size of the keyboard
        guard
            let keyboardSize =
                (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey]
                as? NSValue)?.cgRectValue
        else { return }

        // 2. Add "Padding" to the bottom of the scroll view equal to the keyboard height
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
        // 1. Reset the padding to zero when keyboard disappears
        let contentInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }

    // MARK: - Cleanup

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Helpers

    func setupHideKeyboardOnTap() {
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
