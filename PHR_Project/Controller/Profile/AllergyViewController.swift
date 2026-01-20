//
//  AllergyViewController.swift
//  PHR_Project
//
//  Created by SDC_USER on 27/11/25.
//

import UIKit

class AllergyViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AddAllergyProtocol {
    
    var allergies: [Allergy] = []
    
    
    
    
    @IBOutlet weak var allergiesTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setting up data
        allergies = AllergyService.shared.fetchAllergies()

        // Do any additional setup after loading the view.
        allergiesTableView.dataSource = self
        allergiesTableView.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshData), name: NSNotification.Name("AllergiesUpdated"), object: nil)
    }
    
    @objc func refreshData() {
        self.allergies = AllergyService.shared.fetchAllergies()
        self.allergiesTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allergies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.allergyCell, for: indexPath) as! AllergyTableViewCell
        cell.configureCell(with: allergies[indexPath.row])
        
        
        
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            if editingStyle == .delete {
                
                // 1. Delete from Service (Database)
                AllergyService.shared.deleteAllergy(at: indexPath.row, notify: false)
                
                // 2. Update Local Array (So the view controller knows it's gone)
                allergies.remove(at: indexPath.row)
                
                // 3. Delete Row Animation
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    
    func addAllergy(allergy: Allergy) {
        AllergyService.shared.addAllergy(allergy)
        allergies = AllergyService.shared.fetchAllergies()
        allergiesTableView.reloadData()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is AddAllergyTableViewController {
            let destinationVC = segue.destination as! AddAllergyTableViewController
            destinationVC.addDelegate = self
        }
    }

}
