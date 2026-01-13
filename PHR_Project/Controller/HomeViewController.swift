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
        updateWaterIntakeUI()
        
        
        //setting up event listeners
        NotificationCenter.default.addObserver(self, selector: #selector(updateUI), name: NSNotification.Name(NotificationNames.profileUpdated), object: nil)
        
        
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Hide the navigation bar
        navigationController?.setNavigationBarHidden(true, animated: animated)

        greetingsLabel.text =
            "Good Morning, \(ProfileService.shared.getProfile().firstName)"
        updateWaterIntakeUI()
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
    
    deinit {
            NotificationCenter.default.removeObserver(self)
    }
    
    private func setupWaterIntakeGestures() {
            
            let incrementTap = UITapGestureRecognizer(target: self, action: #selector(incrementGlassCount))
            glassIncrement.addGestureRecognizer(incrementTap)
            
            let decrementTap = UITapGestureRecognizer(target: self, action: #selector(decrementGlassCount))
            glassDecrement.addGestureRecognizer(decrementTap)
        }
    
    @objc private func incrementGlassCount() {
        WaterIntakeService.shared.incrementGlass()
        updateWaterIntakeUI()
        animateGlassValue()
               // Optional: Add haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
         
    }
    
    @objc private func decrementGlassCount() {
        WaterIntakeService.shared.decrementGlass()
        updateWaterIntakeUI()
        animateGlassValue()
        
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    @objc private func updateWaterIntakeUI() {
        let count = WaterIntakeService.shared.getGlassCount()
        glassValue.text = "\(count)"
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
