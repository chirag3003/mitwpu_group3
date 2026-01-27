//
//  MealDetailViewController.swift
//  PHR_Project
//
//  Created by Sushant Pulipati on 26/11/25.
//

import UIKit

class MealDetailViewController: UIViewController {

    // MARK: - IB OUTLETS
    // Header & Media
    @IBOutlet weak var mealImage: UIImageView!
    @IBOutlet weak var mealName: UILabel!
    
    // Nutrition Cards
    @IBOutlet weak var calorieCard: UIView!
    @IBOutlet weak var carbsCard: UIView!
    @IBOutlet weak var proteinCard: UIView!
    @IBOutlet weak var fiberCard: UIView!
    
    // Nutrition Labels
    @IBOutlet weak var calorieCardValue: UILabel!
    @IBOutlet weak var carbsCardDetail: UILabel!
    @IBOutlet weak var proteinCardDetail: UILabel!
    @IBOutlet weak var fiberCardDetail: UILabel!

    // Information Table & Notes
    @IBOutlet weak var mealDetailTableView: UITableView!
    @IBOutlet weak var notesView: UIView!
    @IBOutlet weak var notesText: UILabel!

    // MARK: - PROPERTIES
    var selectedMeal: Meal?

    // MARK: - LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
        setupComponentStyles()
        populateMealDetails()
    }

    // MARK: - SETUP
    // Configure table view delegates and appearance
    private func setupTableView() {
        mealDetailTableView.dataSource = self
        mealDetailTableView.delegate = self
        mealDetailTableView.addRoundedCorner()
    }

    // Apply corner radii and visual styling to all cards
    private func setupComponentStyles() {
        let standardRadius: CGFloat = 10
        
        mealImage.addRoundedCorner(radius: standardRadius)
        calorieCard.addRoundedCorner(radius: standardRadius)
        carbsCard.addRoundedCorner(radius: standardRadius)
        proteinCard.addRoundedCorner(radius: standardRadius)
        fiberCard.addRoundedCorner(radius: standardRadius)
        
        notesView.addRoundedCorner(radius: 20)
        notesText.addRoundedCorner(radius: standardRadius)
    }

    // Bind meal data to UI elements
    private func populateMealDetails() {
        guard let meal = selectedMeal else { return }

        // Set meal image if valid URL exists
        if let imagePath = meal.image, !imagePath.isEmpty,
           imagePath.lowercased().hasPrefix("https") {
            mealImage.setImageFromURL(url: imagePath)
        }

        // Display basic meal info
        mealName.text = meal.name
        notesText.text = meal.notes ?? "No notes"

        // Update nutrition values
        calorieCardValue.text = "\(meal.calories)kcal"
        carbsCardDetail.text = "\(meal.carbs)g"
        proteinCardDetail.text = "\(meal.protein)g"
        fiberCardDetail.text = "\(meal.fiber)g"
    }
}

// MARK: - TABLE VIEW DATA SOURCE
extension MealDetailViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    // Configure cells for meal metadata (Date and Contributor)
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "meal_detail_cell",
            for: indexPath
        ) as! MealDetailTableViewCell

        guard let meal = selectedMeal else { return cell }

        if indexPath.row == 0 {
            cell.dataLabel?.text = "Date"
            
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            cell.dataValue?.text = formatter.string(from: meal.dateRecorded)
            
        } else if indexPath.row == 1 {
            cell.dataLabel?.text = "Added by"
            cell.dataValue?.text = meal.addedBy
        }

        return cell
    }
}
