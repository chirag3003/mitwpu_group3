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

    var selectedMeal: Meal?

    @IBOutlet weak var notesView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        mealDetailTableView.dataSource = self
        mealDetailTableView.delegate = self

        setupUI()
    }

    func setupUI() {
        guard let meal = selectedMeal else { return }

        // Image
        if let imagePath = meal.image, !imagePath.isEmpty,
            imagePath.lowercased().hasPrefix("https")
        {
            mealImage.setImageFromURL(url: imagePath)
        }
        mealImage.addRoundedCorner(radius: 10)

        mealName.text = meal.name

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
        notesText.text = meal.notes ?? "No notes"
    }

}

extension MealDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)
        -> Int
    {
        return 2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell
    {
        let cell =
            tableView.dequeueReusableCell(
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
