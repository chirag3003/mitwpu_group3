//
//  AddMealModalViewController.swift
//  PHR_Project
//
//  Created by Sushant Pulipati on 09/12/25.
//

import UIKit

class AddMealModalViewController: UIViewController {

    @IBOutlet weak var mealType: UIButton!
    @IBOutlet weak var viewThree: UIView!
    @IBOutlet weak var viewTwo: UIView!
    @IBOutlet weak var viewOne: UIView!
    
    var selectedMeal: String?
    
    @IBOutlet weak var notesTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMealMenu()
        
        viewOne.addRoundedCorner()
        viewTwo.addRoundedCorner()
        viewThree.addRoundedCorner()
        notesTextField.addRoundedCorner(radius: 20)

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func setupMealMenu() {
        let options = ["Breakfast", "Lunch", "Dinner"]
        var actions: [UIAction] = []

        for option in options {
            actions.append(
                UIAction(title: option) { [weak self] action in
                    self?.selectedMeal = action.title
                    self?.mealType.setTitle(action.title, for: .normal)
                }
            )
        }
        mealType.menu = UIMenu(children: actions)
        mealType.showsMenuAsPrimaryAction = true
    }
    
    @IBAction func doneButton(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        dismiss(animated: true)
    }
    
}
