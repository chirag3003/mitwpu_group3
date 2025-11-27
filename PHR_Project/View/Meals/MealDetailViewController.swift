//
//  MealDetailViewController.swift
//  PHR_Project
//
//  Created by Sushant Pulipati on 26/11/25.
//

import UIKit

class MealDetailViewController: UIViewController {
    @IBOutlet weak var headerLabel: UILabel!
    
   
    @IBOutlet weak var calorieCard: UIView!
   
    @IBOutlet weak var calorieCardValue: UILabel!
    @IBOutlet weak var mealDetailTableView: UITableView!
    @IBOutlet weak var mealName: UILabel!
    @IBOutlet weak var mealImage: UIImageView!
    
    
    private var mealDetails: [MealDetails] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mealDetails = MealDataStore.shared.getMealDetails()
        
        mealDetailTableView.dataSource = self
        mealDetailTableView.delegate = self
        
        headerLabel.text = "Meal Details"
        headerLabel.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        
        let image = mealDetails[0].mealImage
        mealImage.image = UIImage(named: image)
        mealImage.addRoundedCorner(radius: 10)
        
        mealName.text = mealDetails[0].meal.name
        
        mealDetailTableView.addRoundedCorner()
        
        calorieCard.addRoundedCorner(radius: 30)
        calorieCardValue.text = "\(mealDetails[0].calories)kcal"
        
        
    }
   
}

extension MealDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "meal_detail_cell", for: indexPath)
        
        if indexPath.row == 0 {
            cell.textLabel?.text = mealDetails[0].date
        } else if indexPath.row == 1 {
            cell.textLabel?.text = mealDetails[0].addedBy
        }
        
        return cell
    }
    
    
}
