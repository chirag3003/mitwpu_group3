//
//  AddGlucoseModalViewController.swift
//  PHR_Project
//
//  Created by Sushant Pulipati on 10/12/25.
//

import UIKit

protocol AddGlucoseDelegate: AnyObject {
    func didAddGlucoseData(point: GlucoseDataPoint)
}

class AddGlucoseModalViewController: UITableViewController {

    @IBOutlet weak var typeButton: UIButton!
    weak var delegate: AddGlucoseDelegate?
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var glucoseTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRecordTypeButton()
        // If needed, additional setup can go here.
    }

   
    // MARK: - Actions
    @IBAction func doneModalButton(_ sender: Any) {
        
        guard let text = glucoseTextField.text, let value = Int(text) else {
                    // Optional: Show an alert if empty
                    return
                }

                // 5. Create the Data Point
                let newPoint = GlucoseDataPoint(date: datePicker.date, value: value)

                // 6. Send data back to the Main Screen
                delegate?.didAddGlucoseData(point: newPoint)

                // 7. Close the Modal
                dismiss(animated: true)
    }

    @IBAction func closeModalButton(_ sender: Any) {
        
        dismiss(animated: true)
    }
    func setupRecordTypeButton() {
        let selectionClosure = { (action: UIAction) in
            print("Record Type Selected: \(action.title)")
            // Add any logic here to save the selection (e.g., self.selectedType = action.title)
        }
        
        let allRecordTypes = ["Fasting", "After Meal"]

        // 1. Map the array of strings into an array of UIAction objects
        let actions: [UIAction] = allRecordTypes.map { typeTitle in

            // 2. Determine the state: Default to "Fasting" being .on
            // Note: If you have a variable like 'savedRecordType', change "Fasting" to that variable.
            let currentState: UIMenuElement.State =
                (typeTitle == "Fasting") ? .on : .off

            // 3. Create the UIAction with the dynamically determined state
            let action = UIAction(
                title: typeTitle,
                state: currentState, // Dynamically set to .on or .off
                handler: selectionClosure
            )
            return action
        }
        
        let menu = UIMenu(children: actions)

        // Assumes your outlet is named 'typeButton'
        typeButton.menu = menu
        typeButton.showsMenuAsPrimaryAction = true
        typeButton.changesSelectionAsPrimaryAction = true
    }
    
}

