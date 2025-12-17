//
//  MealDetailViewController.swift
//  PHR_Project
//
//  Created by Sushant Pulipati on 26/11/25.
//

import UIKit

class MealDetailViewController: UIViewController {
   
    @IBOutlet weak var calorieCard: UIView!
   
    @IBOutlet weak var calorieCardValue: UILabel!
    @IBOutlet weak var mealDetailTableView: UITableView!
    @IBOutlet weak var mealName: UILabel!
    @IBOutlet weak var mealImage: UIImageView!
    
    @IBOutlet weak var carbsCardDetail: UILabel!
    @IBOutlet weak var carbsCard: UIView!
    
    @IBOutlet weak var proteinCardDetail: UILabel!
    @IBOutlet weak var proteinCard: UIView!
    
    @IBOutlet weak var fiberCardDetail: UILabel!
    @IBOutlet weak var fiberCard: UIView!
    
    @IBOutlet weak var notesText: UILabel!
    
    //private var mealDetails: [MealDetails] = []
    var selectedMealDetail: MealDetails?
    
    
    @IBOutlet weak var notesView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        mealDetailTableView.dataSource = self
        mealDetailTableView.delegate = self

        
        setupUI()
        
    }
    
    func setupUI() {
            // CHANGE 2: Safely unwrap the selected meal.
            // If it's nil (error), we return so the app doesn't crash.
            guard let meal = selectedMealDetail else { return }
            
            // Use 'meal' instead of 'mealDetails[0]'
            let image = meal.mealImage
            // Safe check for empty image string
            if !image.isEmpty {
                mealImage.image = UIImage(named: image)
            }
            mealImage.addRoundedCorner(radius: 10)
            
            mealName.text = meal.meal.name
            
            mealDetailTableView.addRoundedCorner()
            
            calorieCard.addRoundedCorner(radius: 10)
            calorieCardValue.text = "\(meal.calories)kcal"
            
            carbsCard.addRoundedCorner(radius: 10)
            carbsCardDetail.text = "\(meal.carbs)g"
            
            proteinCard.addRoundedCorner(radius: 10)
            proteinCardDetail.text = "\(meal.protein)g"
            
            fiberCard.addRoundedCorner(radius: 10)
            fiberCardDetail.text = "\(meal.fiber)g"
            
            notesView.addRoundedCorner(radius: 20)
            
            notesText.addRoundedCorner(radius: 10)
            notesText.text = meal.notes
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "meal_detail_cell", for: indexPath) as! MealDetailTableViewCell
        
        guard let meal = selectedMealDetail else { return cell }
        
        if indexPath.row == 0 {
            cell.dataLabel?.text = "Date"
            cell.dataValue?.text = meal.date
        } else if indexPath.row == 1 {
            cell.dataLabel?.text = "Added by"
            cell.dataValue?.text = meal.addedBy
        }
        
        return cell
    }
    
    
}
