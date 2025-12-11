//
//  AddMealModalViewController.swift
//  PHR_Project
//
//  Created by Sushant Pulipati on 09/12/25.
//

import UIKit

class AddMealModalViewController: UITableViewController{

    @IBOutlet weak var mealMenu: UIButton!
    
    var selectedMeal: String?
   
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMealMenu()
        
        

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
                    self?.mealMenu.setTitle(action.title, for: .normal)
                }
            )
        }
        mealMenu.menu = UIMenu(children: actions)
        mealMenu.showsMenuAsPrimaryAction = true
    }
    
    @IBAction func doneButton(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        dismiss(animated: true)
    }
    
}
