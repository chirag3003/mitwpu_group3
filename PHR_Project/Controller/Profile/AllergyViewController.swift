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
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allergies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "allergy_cell", for: indexPath) as! AllergyTableViewCell
        cell.configureCell(with: allergies[indexPath.row])
        return cell
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
