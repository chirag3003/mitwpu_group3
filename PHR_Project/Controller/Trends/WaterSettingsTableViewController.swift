//
//  WaterSettingsTableViewController.swift
//  PHR_Project
//
//  Created by SDC-USER on 20/01/26.
//

import UIKit

class WaterSettingsTableViewController: UITableViewController {
    
    @IBOutlet weak var measuredInButton: UIButton!
    
    @IBOutlet weak var glassesLabel: UILabel!
    @IBOutlet weak var glassesStepper: UIStepper!
    
    var selectedUnit: String = "Liters"
        var glassCount: Int = 8
        var selectedTimeInterval: String = "60 minutes"
        
        // Group controls for easier toggling
        var allButtons: [UIButton] = []
        var allSteppers: [UIStepper] = []
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        allButtons = [measuredInButton]
        allSteppers = [glassesStepper]
        
        // Load the saved target glasses (default to 10 if not set)
        let savedCount = UserDefaults.standard.integer(forKey: "targetWaterGlasses")
        glassCount = savedCount > 0 ? savedCount : 10
        
        setupMeasuredInButton()
        setupGlassesStepper()
        
        updateControlsState(isEditing: false)
    }
        
        // MARK: - Edit Mode Override
        
        override func setEditing(_ editing: Bool, animated: Bool) {
            super.setEditing(editing, animated: animated)
            
            // Update controls state based on edit mode
            updateControlsState(isEditing: editing)
        }
        
        // MARK: - Form State Management
        
        func updateControlsState(isEditing: Bool) {
            // Enable/disable all buttons
            for button in allButtons {
                button.isUserInteractionEnabled = isEditing
                button.tintColor = isEditing ? .systemBlue : .label
                button.alpha = isEditing ? 1.0 : 0.6
            }
            
            // Enable/disable all steppers
            for stepper in allSteppers {
                stepper.isUserInteractionEnabled = isEditing
                stepper.alpha = isEditing ? 1.0 : 0.6
            }
        }
        
        // MARK: - Stepper Setup
        
        func setupGlassesStepper() {
            glassesStepper.minimumValue = 1
            glassesStepper.maximumValue = 20
            glassesStepper.stepValue = 1
            glassesStepper.value = Double(glassCount)
            
            glassesStepper.addTarget(self, action: #selector(stepperValueChanged), for: .valueChanged)
            
            updateGlassesLabel()
        }
        
    @objc func stepperValueChanged(_ stepper: UIStepper) {
        glassCount = Int(stepper.value)
        UserDefaults.standard.set(glassCount, forKey: "targetWaterGlasses")
        updateGlassesLabel()
    }
        
        func updateGlassesLabel() {
            glassesLabel.text = "\(glassCount)"
        }
        
        // MARK: - Measured In Button Setup
        
        func setupMeasuredInButton() {
            let selectionClosure: UIActionHandler = { [weak self] action in
                guard let self = self else { return }
                
                self.selectedUnit = action.title
            }
            
            let unitOptions = ["Liters (L)", "Ounces (oz)"]
            
            let actions: [UIAction] = unitOptions.map { title in
                let currentState: UIMenuElement.State = (title == selectedUnit) ? .on : .off
                
                let action = UIAction(
                    title: title,
                    state: currentState,
                    handler: selectionClosure
                )
                return action
            }
            
            let menu = UIMenu(children: actions)
            
            measuredInButton.menu = menu
            measuredInButton.showsMenuAsPrimaryAction = true
            measuredInButton.changesSelectionAsPrimaryAction = true
        }
        
        
        // MARK: - Disable Table Editing UI
        
        override func tableView(
            _ tableView: UITableView,
            editingStyleForRowAt indexPath: IndexPath
        ) -> UITableViewCell.EditingStyle {
            return .none
        }
        
        override func tableView(
            _ tableView: UITableView,
            shouldIndentWhileEditingRowAt indexPath: IndexPath
        ) -> Bool {
            return false
        }
    }
