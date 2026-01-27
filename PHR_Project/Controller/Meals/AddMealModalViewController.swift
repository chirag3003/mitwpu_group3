//
//  AddMealModalViewController.swift
//  PHR_Project
//
//  Created by Sushant Pulipati on 09/12/25.
//

import UIKit


class AddMealModalViewController: UITableViewController {

    // MARK: Outlets
    @IBOutlet weak var mealName: UITextField!
    @IBOutlet var addMealTableView: UITableView!
    @IBOutlet weak var mealMenu: UIButton!
    @IBOutlet weak var qtyStepper: UIStepper!
    @IBOutlet weak var stepperValue: UILabel!
    @IBOutlet weak var mealDate: UIDatePicker!
    @IBOutlet weak var mealTime: UIDatePicker!

    // MARK: Properties
    var selectedMeal: String?

    
    // MARK: Lifecycle
    //Initial setup when view loads
    override func viewDidLoad() {
        super.viewDidLoad()

        setupMealMenu()
        addMealTableView.backgroundColor = .systemGray6
        updateStepperLabel()
    }

    
    // MARK: Setup
    //Configure meal type dropdown menu
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

    
    // MARK: Stepper Control
    //Update quantity when stepper changes
    @IBAction func stepperValueChanged(_ sender: UIStepper) {
        updateStepperLabel()
    }

    //Display current stepper value
    func updateStepperLabel() {
        stepperValue.text = "\(Int(qtyStepper.value))"
    }

    
    // MARK: Actions
    //Validate inputs and save meal
    @IBAction func doneButton(_ sender: Any) {
        // Validate meal name
        guard let name = mealName.text, !name.isEmpty else {
            self.showAlert(
                title: "Missing info",
                message: "Please enter a meal name"
            )
            return
        }

        // Validate meal type
        guard let type = selectedMeal else {
            self.showAlert(
                title: "Missing info",
                message: "Please select Meal Type"
            )
            return
        }

        // Format time
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a"
        let timeString = timeFormatter.string(from: mealTime.date)

        // Format serving detail
        let qty = Int(qtyStepper.value)
        let detailString = "\(qty) serving(s)"

        // Pick image based on meal type
        let imageName: String
        if type == "Breakfast" {
            imageName = "coffee"
        } else {
            imageName = "dal"
        }

        // Create meal object
        let newMeal = Meal(
            id: UUID(),
            name: name,
            detail: detailString,
            time: timeString,
            image: imageName,
            type: type,
            dateRecorded: mealDate.date,
            calories: 0,
            protein: 0,
            carbs: 0,
            fiber: 0,
            addedBy: "Self",
            notes: nil
        )

        // Save meal
        MealService.shared.addMeal(newMeal)

        // Close modal
        dismiss(animated: true)
    }

    //Close modal without saving
    @IBAction func cancelButton(_ sender: Any) {
        dismiss(animated: true)
    }
}
