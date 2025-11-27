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
    private var mealDetails: [MealDetails] = []
    
    
    @IBOutlet weak var notesView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mealDetails = MealDataStore.shared.getMealDetails()
        
        mealDetailTableView.dataSource = self
        mealDetailTableView.delegate = self
//        
//        headerLabel.text = "Meal Details"
//        headerLabel.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        
        let image = mealDetails[0].mealImage
        mealImage.image = UIImage(named: image)
        mealImage.addRoundedCorner(radius: 10)
        
        mealName.text = mealDetails[0].meal.name
        
        mealDetailTableView.addRoundedCorner()
        
        calorieCard.addRoundedCorner(radius: 10)
        calorieCardValue.text = "\(mealDetails[0].calories)kcal"
        
        carbsCard.addRoundedCorner(radius: 10)
        carbsCardDetail.text = "\(mealDetails[0].carbs)g"
        
        proteinCard.addRoundedCorner(radius: 10)
        proteinCardDetail.text = "\(mealDetails[0].protein)g"
        
        fiberCard.addRoundedCorner(radius: 10)
        fiberCardDetail.text = "\(mealDetails[0].fiber)g"
        
        notesView.addRoundedCorner(radius: 20)
        
        notesText.addRoundedCorner(radius: 10)
        notesText.text = mealDetails[0].notes
        
        
        
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
