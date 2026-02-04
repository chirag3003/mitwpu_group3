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

    override func tableView(
        _ tableView: UITableView,
        viewForHeaderInSection section: Int
    ) -> UIView? {

        // Create a container view
        let headerView = UIView()
        headerView.backgroundColor = .clear

        // Create the label
        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)  // Larger and Bolder
        titleLabel.textColor = .label  // Standard Black (or White in Dark Mode)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        // Set the text based on the section index
        switch section {
        case 0:
            titleLabel.text = "Time Range"
        case 1:
            titleLabel.text = "Select Data Fields"
        case 2:
            titleLabel.text = "Additional Notes"
        default:
            return nil
        }

        // Add label to the container
        headerView.addSubview(titleLabel)

        NSLayoutConstraint.activate([

            titleLabel.leadingAnchor.constraint(
                equalTo: headerView.leadingAnchor,
                constant: 20
            ),

            titleLabel.bottomAnchor.constraint(
                equalTo: headerView.bottomAnchor,
                constant: -8
            ),

            titleLabel.topAnchor.constraint(
                equalTo: headerView.topAnchor,
                constant: 15
            ),
        ])

        return headerView
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
