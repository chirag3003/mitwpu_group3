//
//  AddAllergyTableViewController.swift
//  PHR_Project
//
//  Created by SDC_USER on 27/11/25.
//

import UIKit

protocol AddAllergyProtocol {
    func addAllergy(allergy: Allergy)
}

class AddAllergyTableViewController: UITableViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var allergyIngredient: UITextField!
    @IBOutlet weak var allergyDetailReaction: UITextField!
    @IBOutlet weak var intensityButton: UIButton!
    
    var addDelegate: AddAllergyProtocol?
    
    // Keep reference to fields for keyboard management if needed
    var allTextFields: [UITextField] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. Setup Data Arrays
        allTextFields = [allergyIngredient, allergyDetailReaction]
        
        // 2. Setup UI
        setupPullDownButton()
        
        // 3. Hide Keyboard on Tap
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        // NOTE: We REMOVED the "self.editButtonItem" line.
        // The text fields will be blank by default as long as they are empty in Storyboard.
    }
    
    // MARK: - Setup Logic
    func setupPullDownButton() {
        let optionClosure: UIActionHandler = { action in
            print("User selected intensity: \(action.title)")
        }

        // Define options
        let option1 = UIAction(title: "Low", handler: optionClosure)
        // We keep Moderate as the default selection for the BUTTON so it's not empty
        let option2 = UIAction(title: "Moderate", state: .on, handler: optionClosure)
        let option3 = UIAction(title: "High", handler: optionClosure)
        
        // Configure Menu
        let menu = UIMenu(children: [option1, option2, option3])
        
        intensityButton.menu = menu
        intensityButton.showsMenuAsPrimaryAction = true
        intensityButton.changesSelectionAsPrimaryAction = true
    }
    
    // MARK: - Actions
    
    // Connect this to your 'Done' or 'Save' bar button item
    @IBAction func saveTapped(_ sender: UIBarButtonItem) {
        
        // 1. Validate Ingredient Name
        // We use guard to ensure the user actually wrote something
        guard let name = allergyIngredient.text, !name.isEmpty else {
            let alert = UIAlertController(title: "Missing Info", message: "Please enter the allergy ingredient.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        // 2. Gather Data
        // If reaction is empty, we save it as an empty string ""
        let reaction = allergyDetailReaction.text ?? ""
        let intensity = intensityButton.currentTitle ?? "Moderate"
        
        // 3. Save Logic (Print for now)
        print("--- SAVING NEW ALLERGY ---")
        print("Ingredient: \(name)")
        print("Reaction: \(reaction)")
        print("Intensity: \(intensity)")
        
        //Adding allergy
        addDelegate?.addAllergy(allergy: Allergy(id: UUID(), name: name, severity: intensity, notes: reaction))
       
        // 4. Go back to previous screen
        navigationController?.popViewController(animated: true)
//        dismiss(animated: true)
    }
    
    // These empty actions are just to satisfy connections if you made them in storyboard
    @IBAction func allergyIngredient(_ sender: UITextField) {}
    @IBAction func allergyDetailReaction(_ sender: Any) {}
    @IBAction func intensityButton(_ sender: UIButton) {}
    
    // MARK: - Helpers
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: - Table View Overrides
    
    // Returns .none to ensure no delete/edit UI ever appears
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    // Important: Do not include numberOfSections or numberOfRowsInSection
    // because you are using Static Cells in Storyboard.
}
    /*
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
     
     // Configure the cell...
     
     return cell
     }
     */
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */


