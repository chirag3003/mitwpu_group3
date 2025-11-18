//
//  HomeViewController.swift
//  PHR_Project
//
//  Created by SDC_USER on 14/11/25.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var mainStack: UIStackView!
    @IBOutlet weak var notificationView: UIView!
    @IBOutlet weak var headerView: UIView!
    
    // MARK: - Health Summary View
    private let healthSummaryView: HealthSummaryView = {
        let view = HealthSummaryView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        notificationView.layer.cornerRadius = 16
        notificationView.clipsToBounds = true
        
        headerView.applyLiquidGlassEffect()
        
        setupHealthSummaryView()
        loadHealthData()

        // Do any additional setup after loading the view.
    }
    
    // MARK: - Setup Health Summary
    private func setupHealthSummaryView() {
        // Add the summary view to the main stack
        mainStack.addArrangedSubview(healthSummaryView)
        
        // Set custom spacing after notification view
        mainStack.setCustomSpacing(24, after: notificationView)
    }
    
    // MARK: - Load Health Data
    private func loadHealthData() {
        // Sample data - replace with actual data from HealthKit or your data source
        let glucose = GlucoseMetric(value: 108)
        let water = WaterIntakeMetric(current: 6, goal: 10)
        let steps = StepsMetric(steps: 5890, caloriesBurned: 250, calorieGoal: 400)
        let calories = CaloriesMetric(consumed: 987, goal: 2000)
        
        healthSummaryView.configure(glucose: glucose, water: water, steps: steps, calories: calories)
    }
    
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            // Hide the navigation bar
            navigationController?.setNavigationBarHidden(true, animated: animated)
        }

        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            // Show the navigation bar for the next screen
            navigationController?.setNavigationBarHidden(false, animated: animated)
        }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
