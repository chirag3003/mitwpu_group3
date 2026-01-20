//
//  AddGlucoseModalViewController.swift
//  PHR_Project
//
//  Created by Sushant Pulipati on 10/12/25.
//

import UIKit

class AddGlucoseModalViewController: UITableViewController {

   
    
    @IBOutlet weak var recordTypeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRecordTypeButton()
        // If needed, additional setup can go here.
    }

   
    // MARK: - Actions
    @IBAction func doneModalButton(_ sender: Any) {
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
        recordTypeButton.menu = menu
        recordTypeButton.showsMenuAsPrimaryAction = true
        recordTypeButton.changesSelectionAsPrimaryAction = true
    }
   
}
