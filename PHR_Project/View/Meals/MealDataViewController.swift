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
//        cell.configure(with:meal)
        
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath){
        
        if editingStyle == .delete{
            mealData.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
   
}

