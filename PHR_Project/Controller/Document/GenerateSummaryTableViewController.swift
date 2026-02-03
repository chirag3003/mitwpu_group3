//
//  GenerateSummaryTableViewController.swift
//  PHR_Project
//
//  Created by SDC_USER on 03/02/26.
//

import UIKit

class GenerateSummaryTableViewController: UITableViewController {

    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    @IBOutlet weak var symptomsSwitch: UISwitch!
    @IBOutlet weak var reportsSwitch: UISwitch!
    @IBOutlet weak var prescriptionsSwitch: UISwitch!
    @IBOutlet weak var trendsSwitch: UISwitch!
    @IBOutlet weak var mealsSwitch: UISwitch!
    @IBOutlet weak var notesTextField: UITextField!
    @IBOutlet weak var generateSummaryButton: UIButton!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTextField()
        setupKeyboardDismissal()
    }

    // MARK: - Setup UI
    func setupTextField() {
        // Removes border for a cleaner look
        notesTextField.borderStyle = .none

    }

    // MARK: - Keyboard Handling
    func setupKeyboardDismissal() {

        tableView.keyboardDismissMode = .interactive

        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissKeyboard)
        )
        tapGesture.cancelsTouchesInView = false  // Important: Allows switches to still work
        view.addGestureRecognizer(tapGesture)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

}
