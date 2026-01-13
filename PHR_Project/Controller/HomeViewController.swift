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

    @IBOutlet weak var glassValue: UILabel!
    @IBOutlet weak var glassDecrement: UIImageView!
    @IBOutlet weak var glassIncrement: UIImageView!
    
    private var currentGlassCount: Int = 0 {
        didSet {
            currentGlassCount = max(0, min(10, currentGlassCount))
            glassValue.text = "\(currentGlassCount)"
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        //Border radius changes 
        notificationView.addRoundedCorner(radius: UIConstants.CornerRadius.medium)
        mealLogCardView.addRoundedCorner()
        symptomLogCard.addRoundedCorner()

        // Liquid Glass Effect
        headerView.applyLiquidGlassEffect()

        // Custom Spacing
        mainStack.setCustomSpacing(UIConstants.Spacing.large, after: notificationView)
        mainStack.setCustomSpacing(UIConstants.Spacing.large, after: circularSummariesStack)

        // UI Layer Adjustments
        headerView.layer.zPosition = 2
        
        // Setting up data
        greetingsLabel.text =
            "Good Morning, \(ProfileService.shared.getProfile().firstName)"
        stepsSummaryCard.configure(mode: .achievement, progress: 0.45, thickness: 16)
        caloriesSummaryCard.configure(mode: .limitWarning, progress: 0.76, thickness: 16)
        
        setupWaterIntakeGestures()
        
        //setting up event listeners
        NotificationCenter.default.addObserver(self, selector: #selector(updateUI), name: NSNotification.Name(NotificationNames.profileUpdated), object: nil)
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
        reloadData()
    }
    
    private func setupWaterIntakeGestures() {
            
            let incrementTap = UITapGestureRecognizer(target: self, action: #selector(incrementGlassCount))
            glassIncrement.addGestureRecognizer(incrementTap)
            
            let decrementTap = UITapGestureRecognizer(target: self, action: #selector(decrementGlassCount))
            glassDecrement.addGestureRecognizer(decrementTap)
        }
    
    @objc private func incrementGlassCount() {
            if currentGlassCount < 10 {
                currentGlassCount += 1
                animateGlassValue()
                // Optional: Add haptic feedback
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
            }
        }
    
    @objc private func decrementGlassCount() {
            if currentGlassCount > 0 {
                currentGlassCount -= 1
                animateGlassValue()
                // Optional: Add haptic feedback
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
            }
        }
    
    private func animateGlassValue() {
            UIView.animate(withDuration: 0.1, animations: {
                self.glassValue.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            }) { _ in
                UIView.animate(withDuration: 0.1) {
                    self.glassValue.transform = .identity
                }
            }
        }

}
