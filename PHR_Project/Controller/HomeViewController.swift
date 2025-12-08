//
//  HomeViewController.swift
//  PHR_Project
//
//  Created by SDC_USER on 14/11/25.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var circularSummariesStack: UIStackView!
    @IBOutlet weak var caloriesSummaryCard: CircularProgressView!
    @IBOutlet weak var stepsSummaryCard: CircularProgressView!
    @IBOutlet weak var greetingsLabel: UILabel!
    @IBOutlet weak var mainStack: UIStackView!
    @IBOutlet weak var notificationView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var mealLogCardView: UIView!
    @IBOutlet weak var symptomLogCard: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        //Add rounded corners
        notificationView.addRoundedCorner(radius: 16)
        mealLogCardView.addRoundedCorner()
        symptomLogCard.addRoundedCorner()

        //Adding views to stack

        //Adding Glass effect to components
        headerView.applyLiquidGlassEffect()

        //Adding custom spacing between stack items
        mainStack.setCustomSpacing(20, after: notificationView)
        mainStack.setCustomSpacing(20, after: circularSummariesStack)

        // Do any additional setup after loading the view.
        headerView.layer.zPosition = 2
        
        // Setting up data
        greetingsLabel.text =
            "Good Morning, \(ProfileService.shared.getProfile().firstName)"
        stepsSummaryCard.setProgress(to: 0.45)
        caloriesSummaryCard.setProgress(to: 0.49)
        
        //setting up event listeners
        NotificationCenter.default.addObserver(self, selector: #selector(updateUI), name: NSNotification.Name("ProfileUpdated"), object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Hide the navigation bar
        navigationController?.setNavigationBarHidden(true, animated: animated)

        greetingsLabel.text =
            "Good Morning, \(ProfileService.shared.getProfile().firstName)"
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Show the navigation bar for the next screen
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    func reloadData() {
        greetingsLabel.text =
            "Good Morning, \(ProfileService.shared.getProfile().firstName)"
    }
    
    @objc func updateUI() {
        let profile = ProfileService.shared.getProfile()
        reloadData()
        // Update your labels here...
    }

}
