//
//  MealDataViewController.swift
//  PHR_Project
//
//  Created by Sushant Pulipati on 25/11/25.
//

import Foundation
import UIKit

class MealDataViewController: UITableViewController
{


    private var mealData: [Meal] = []
    private var isDeleting = false

    override func viewDidLoad() {
        navigationItem.rightBarButtonItem = editButtonItem
        super.viewDidLoad()

        mealData = MealService.shared.getAllMeals()

        //setting up table view
        tableView.dataSource = self
        tableView.delegate = self
        tableView.addRoundedCorner()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateMealData),
            name: NSNotification.Name(NotificationNames.mealsUpdated),
            object: nil
        )
    }

    @objc func updateMealData() {
        // Skip reload if we're in the middle of an animated delete
        guard !isDeleting else { return }
        mealData = MealService.shared.getAllMeals()
        tableView.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if let detailVC = segue.destination as? MealDetailViewController,
            let cell = sender as? UITableViewCell,
            let indexPath = tableView.indexPath(for: cell)
        {
            // We ensure we don't crash if the arrays have different lengths
            if indexPath.row < mealData.count {
                let selectedMeal = mealData[indexPath.row]
                detailVC.selectedMeal = selectedMeal
            } else {
                print("Error: No details found for row \(indexPath.row)")
            }
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)
        -> Int
    {
        return mealData.count
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "meal_cell",
            for: indexPath
        )

        let meal = mealData[indexPath.row]
        cell.textLabel?.text = meal.name

        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .none
        return cell
    }

    override func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath
    ) {
        if editingStyle == .delete {
            let mealToDelete = mealData[indexPath.row]
            
            isDeleting = true
            
            mealData.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
            MealService.shared.deleteMeal(mealToDelete)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                self?.isDeleting = false
            }
        }
    }

}
