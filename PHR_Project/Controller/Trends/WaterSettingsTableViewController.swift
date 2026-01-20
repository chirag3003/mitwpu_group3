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
    @IBOutlet weak var timeButton: UIButton!
    @IBOutlet weak var glassesStepper: UIStepper!
    
    var selectedUnit: String = "Liters"
    var glassCount: Int = 8
    var selectedTimeInterval: String = "60 minutes"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMeasuredInButton()
        setupTimeButton()
        setupGlassesStepper()
        
    }
    
    func setupGlassesStepper() {
        glassesStepper.value = Double(glassCount)
        
        glassesStepper.addTarget(self, action: #selector(stepperValueChanged), for: .valueChanged)
        
        updateGlassesLabel()
    }
    
    @objc func stepperValueChanged(_ stepper: UIStepper) {
        glassCount = Int(stepper.value)
        updateGlassesLabel()
//        saveSettings()
    }
    
    
    func updateGlassesLabel() {
        glassesLabel.text = "\(glassCount)"
    }
    
    func setupMeasuredInButton() {
        let selectionClosure: UIActionHandler = { [weak self] action in
            
            self?.selectedUnit = action.title
            print("Measurement Unit Selected: \(action.title)")
            
            //self?.saveSettings()
        }
        
        let unitOptions = ["Liters (L)", " Ounces (oz)"]
        
        let actions: [UIAction] = unitOptions.map { title in
           
            let currentState: UIMenuElement.State = (title == selectedUnit) ? .on : .off
            
            let action = UIAction(
                title: title,
                state: currentState,
                handler: selectionClosure
            )
            return action
        }
        
        // Create the menu
        let menu = UIMenu(children: actions)
        
        // Configure the button
        measuredInButton.menu = menu
        measuredInButton.showsMenuAsPrimaryAction = true
        measuredInButton.changesSelectionAsPrimaryAction = true
    }
    
    func setupTimeButton() {
        let selectionClosure: UIActionHandler = { [weak self] action in
            // Update the selected time interval
            self?.selectedTimeInterval = action.title
            print("Time Interval Selected: \(action.title) hours")
            // Save the preference
//            self?.saveSettings()
        }
        
        let timeOptions = ["30 minutes", "45 minutes", "60 minutes", "90 minutes"]
        
        let actions: [UIAction] = timeOptions.map { title in
            // Determine the state: if the title matches selectedTimeInterval, set state to .on
            let currentState: UIMenuElement.State = (title == selectedTimeInterval) ? .on : .off
            
            let action = UIAction(
                title: title,
                state: currentState,
                handler: selectionClosure
            )
            return action
        }
        
        // Create the menu
        let menu = UIMenu(children: actions)
        
        // Configure the button
        timeButton.menu = menu
        timeButton.showsMenuAsPrimaryAction = true
        timeButton.changesSelectionAsPrimaryAction = true
    }
    
}
