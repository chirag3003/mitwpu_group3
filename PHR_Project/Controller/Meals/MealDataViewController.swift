//
//  MealDataViewController.swift
//  PHR_Project
//
//  Created by Sushant Pulipati on 25/11/25.
//

import UIKit

class MealDataViewController: UIViewController {

    // MARK: - IB OUTLETS
    @IBOutlet weak var mealTableView: UITableView!

    // MARK: - PROPERTIES
    private var mealData: [Meal] = []
    private var isDeleting = false

    // MARK: - LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setupTableView()
        setupNotifications()
        fetchInitialData()
    }

    // Handle navigation to Detail screen
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let detailVC = segue.destination as? MealDetailViewController,
              let cell = sender as? UITableViewCell,
              let indexPath = mealTableView.indexPath(for: cell) else {
            return
        }

        // Ensure index is within bounds to prevent crashes
        if indexPath.row < mealData.count {
            detailVC.selectedMeal = mealData[indexPath.row]
        } else {
            print("Error: No details found for row \(indexPath.row)")
        }
    }

    // MARK: - SETUP
    // Configure the navigation bar items
    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = editButtonItem
    }

    // Assign delegates and style the table
    private func setupTableView() {
        mealTableView.dataSource = self
        mealTableView.delegate = self
        mealTableView.addRoundedCorner()
    }

    // Load data from the shared service
    private func fetchInitialData() {
        mealData = MealService.shared.getAllMeals()
    }

    // Listen for data updates from other parts of the app
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateMealData),
            // Note: Verify if this should be 'mealsUpdated' instead of 'symptomsUpdated'
            name: NSNotification.Name(NotificationNames.symptomsUpdated),
            object: nil
        )
    }

    // MARK: - ACTIONS
    // Refresh data and UI when notification is received
    @objc func updateMealData() {
        // Skip reload if we're in the middle of an animated delete
        guard !isDeleting else { return }
        mealData = MealService.shared.getAllMeals()
        mealTableView.reloadData()
    }

    // Synchronize ViewController editing state with TableView
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        mealTableView.setEditing(editing, animated: animated)
    }
}

// MARK: - TABLE VIEW DATA SOURCE & DELEGATE
extension MealDataViewController: UITableViewDataSource, UITableViewDelegate {

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mealData.count
    }

    // Configure the appearance of each meal row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "meal_cell",
            for: indexPath
        )

        let meal = mealData[indexPath.row]
        cell.textLabel?.text = meal.name
        
        // UI Enhancements
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .none
        
        return cell
    }

    // Handle row deletion
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let mealToDelete = mealData[indexPath.row]
            
            isDeleting = true
            
            mealData.remove(at: indexPath.row)
            
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}
