//
//  MealDataViewController.swift
//  PHR_Project
//
//  Created by Sushant Pulipati on 25/11/25.
//

import UIKit
import Foundation

class MealDataViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var mealTableView: UITableView!
    
    private var mealData: [MealItem] = []
    
    
    override func viewDidLoad() {
        navigationItem.rightBarButtonItem = editButtonItem
        super.viewDidLoad()
        
        mealData = MealDataStore.shared.getMealItem()
        
        //setting up table view
        mealTableView.dataSource = self
        mealTableView.delegate = self
        mealTableView.addRoundedCorner()
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            
            // 1. Check if the destination is the Detail View Controller
            if let detailVC = segue.destination as? MealDetailViewController,
               // 2. Check which cell was tapped
               let cell = sender as? UITableViewCell,
               let indexPath = mealTableView.indexPath(for: cell) {
                
                // 3. Get the full list of details
                let allDetails = MealDataStore.shared.getMealDetails()
                
                // 4. CRITICAL FIX: Match by Row Index
                // We ensure we don't crash if the arrays have different lengths
                if indexPath.row < allDetails.count {
                    let selectedDetail = allDetails[indexPath.row]
                    detailVC.selectedMealDetail = selectedDetail
                } else {
                    print("Error: No details found for row \(indexPath.row)")
                }
            }
        }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mealData.count
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        mealTableView.setEditing(editing, animated: animated)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "meal_cell", for: indexPath)
        
        let meal = mealData[indexPath.row]
        cell.textLabel?.text = meal.name
        
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath){
        
        if editingStyle == .delete{
            mealData.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
   
}

