//
//  AddMealModalViewController.swift
//  PHR_Project
//
//  Created by Sushant Pulipati on 09/12/25.
//

import UIKit

class AddMealModalViewController: UITableViewController{

    @IBOutlet weak var mealName: UITextField!
    @IBOutlet var addMealTableView: UITableView!
    @IBOutlet weak var mealMenu: UIButton!
    @IBOutlet weak var qtyStepper: UIStepper!
    @IBOutlet weak var stepperValue: UILabel!
    
    @IBOutlet weak var mealDate: UIDatePicker!
    @IBOutlet weak var mealTime: UIDatePicker!
    
    var selectedMeal: String?
   
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMealMenu()
        addMealTableView.backgroundColor = .systemGray6
        updateStepperLabel()
        
    }
    
    func setupMealMenu() {
        let options = ["Breakfast", "Lunch", "Dinner"]
        var actions: [UIAction] = []

        for option in options {
            actions.append(
                UIAction(title: option) { [weak self] action in
                    self?.selectedMeal = action.title
                    self?.mealMenu.setTitle(action.title, for: .normal)
                }
            )
        }
        mealMenu.menu = UIMenu(children: actions)
        mealMenu.showsMenuAsPrimaryAction = true
    }
    
    @IBAction func stepperValueChanged(_ sender: UIStepper) {
        updateStepperLabel()
    }
    
    func updateStepperLabel() {
        stepperValue.text = "\(Int(qtyStepper.value))"
   }
    
    
    @IBAction func doneButton(_ sender: Any) {
        // 1. Validation
                guard let name = mealName.text, !name.isEmpty else {
                    showAlert(message: "Please enter a meal name")
                    return
                }
                
                guard let type = selectedMeal else {
                    showAlert(message: "Please select Meal Type")
                    return
                }
                
                // 2. Format Time
                let timeFormatter = DateFormatter()
                timeFormatter.dateFormat = "h:mm a"
                let timeString = timeFormatter.string(from: mealTime.date)
                
                // 3. Format Detail
                let qty = Int(qtyStepper.value)
                let detailString = "\(qty) serving(s)"
                
                // 4. Handle Image
                let imageName: String
                if type == "Breakfast" {
                    imageName = "coffee"
                } else {
                    imageName = "dal"
                }
                
                // 5. Create the Meal Object (UPDATED HERE)
                let newMeal = Meal(
                    id: UUID(),                  // ADDED: Generate a unique ID
                    name: name,
                    detail: detailString,
                    time: timeString,
                    image: imageName,
                    type: type,
                    dateRecorded: mealDate.date  // ADDED: Pass the selected date
                )

                // 6. Save using the Service (UNCOMMENT THIS)
                MealService.shared.addMeal(newMeal)
                
                // 7. Dismiss
                dismiss(animated: true)
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        dismiss(animated: true)
    }
    
    func showAlert(message: String) {
            let alert = UIAlertController(title: "Missing Info", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
    }
    
}
