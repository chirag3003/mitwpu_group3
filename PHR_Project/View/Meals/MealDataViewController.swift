//
//  MealDataViewController.swift
//  PHR_Project
//
//  Created by Sushant Pulipati on 25/11/25.
//

import UIKit
import Foundation

class MealDataViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var mealTableView: UITableView!
    
    private var mealData: [MealItem] = []
    
    private func fetchMealData(){
        mealData = [
            MealItem(id: UUID(), name: "Pancakes and Fruits"),
            MealItem(id: UUID(), name: "Omelette and Toast"),
            MealItem(id: UUID(), name: "Grilled Chicken and Vegetables"),
            MealItem(id: UUID(), name: "Beef Stir Fry"),
            MealItem(id: UUID(), name: "Spaghetti with Marinara Sauce")
        ]
    }
    
    
    override func viewDidLoad() {
        navigationItem.rightBarButtonItem = editButtonItem
        super.viewDidLoad()
        
        fetchMealData()
        
        //setting up table view
        mealTableView.dataSource = self
        mealTableView.delegate = self
        mealTableView.addRoundedCorner()
        
        headerLabel.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        
    
        
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mealData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "meal_cell", for: indexPath)
        
        let meal = mealData[indexPath.row]
        cell.textLabel?.text = meal.name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath){
        
        if editingStyle == .delete{
            mealData.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
   
}

