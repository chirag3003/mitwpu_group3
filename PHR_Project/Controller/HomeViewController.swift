//
//  HomeViewController.swift
//  PHR_Project
//
//  Created by SDC_USER on 14/11/25.
//

import UIKit

/// Main dashboard screen displaying health summaries, water intake tracking,
/// and quick access to meal/symptom logging.
final class HomeViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    // Header
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var greetingsLabel: UILabel!
    @IBOutlet weak var notificationView: UIView!
    
    // Summary Cards
    @IBOutlet weak var glucoseCard: SummaryCardView!
    @IBOutlet weak var circularSummariesStack: UIStackView!
    @IBOutlet weak var caloriesSummaryCard: CircularProgressView!
    @IBOutlet weak var stepsSummaryCard: CircularProgressView!
    
    // Water Intake
    @IBOutlet weak var waterIntakeCard: SummaryCardView!
    @IBOutlet weak var glassValue: UILabel!
    @IBOutlet weak var glassDecrement: UIImageView!
    @IBOutlet weak var glassIncrement: UIImageView!
    
    // Quick Actions
    @IBOutlet weak var mainStack: UIStackView!
    @IBOutlet weak var mealLogCardView: UIView!
    @IBOutlet weak var symptomLogCard: UIView!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupGestures()
        setupNotificationObservers()
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        refreshData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Setup

private extension HomeViewController {
    
    func setupUI() {
        configureCardAppearance()
        configureHeaderAppearance()
        configureStackSpacing()
    }
    
    func configureCardAppearance() {
        notificationView.addRoundedCorner(radius: UIConstants.CornerRadius.medium)
        mealLogCardView.addRoundedCorner()
        symptomLogCard.addRoundedCorner()
    }
    
    func configureHeaderAppearance() {
        headerView.applyLiquidGlassEffect()
        headerView.layer.zPosition = 2
    }
    
    func configureStackSpacing() {
        mainStack.setCustomSpacing(UIConstants.Spacing.large, after: notificationView)
        mainStack.setCustomSpacing(UIConstants.Spacing.large, after: circularSummariesStack)
    }
    
    func setupGestures() {
        setupWaterIntakeGestures()
        setupGlucoseCardGesture()
        setupWaterIntakeCardGesture()
    }
    
    func setupNotificationObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleProfileUpdate),
            name: NSNotification.Name(NotificationNames.profileUpdated),
            object: nil
        )
    }
}

// MARK: - Data Loading

private extension HomeViewController {
    
    func loadData() {
        updateGreeting()
        configureSummaryCards()
        updateWaterIntakeUI()
    }
    
    func refreshData() {
        updateGreeting()
        updateWaterIntakeUI()
    }
    
    func updateGreeting() {
        let firstName = ProfileService.shared.getProfile().firstName
        greetingsLabel.text = "Good Morning, \(firstName)"
    }
    
    func configureSummaryCards() {
        stepsSummaryCard.configure(mode: .achievement, progress: 0.45, thickness: 16)
        caloriesSummaryCard.configure(mode: .limitWarning, progress: 0.76, thickness: 16)
    }
    
    @objc func handleProfileUpdate() {
        updateGreeting()
    }
}

// MARK: - Water Intake

private extension HomeViewController {
    
    func setupWaterIntakeGestures() {
        let incrementTap = UITapGestureRecognizer(target: self, action: #selector(incrementGlassCount))
        glassIncrement.addGestureRecognizer(incrementTap)
        
        let decrementTap = UITapGestureRecognizer(target: self, action: #selector(decrementGlassCount))
        glassDecrement.addGestureRecognizer(decrementTap)
    }
    
    @objc func incrementGlassCount() {
        WaterIntakeService.shared.incrementGlass()
        updateWaterIntakeUI()
        animateGlassValue()
        provideHapticFeedback()
    }
    
    @objc func decrementGlassCount() {
        WaterIntakeService.shared.decrementGlass()
        updateWaterIntakeUI()
        animateGlassValue()
        provideHapticFeedback()
    }
    
    func updateWaterIntakeUI() {
        let count = WaterIntakeService.shared.getGlassCount()
        glassValue.text = "\(count)"
    }
    
    func animateGlassValue() {
        UIView.animate(withDuration: 0.1, animations: {
            self.glassValue.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.glassValue.transform = .identity
            }
        }
    }
}

// MARK: - Glucose Card Navigation

private extension HomeViewController {
    
    func setupGlucoseCardGesture() {
        glucoseCard.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(glucoseCardTapped))
        glucoseCard.addGestureRecognizer(tapGesture)
    }
    
    @objc func glucoseCardTapped() {
        performSegue(withIdentifier: "glucoseSegue", sender: self)
    }
}

// MARK: - Water Intake Card Navigation

private extension HomeViewController {
    
    func setupWaterIntakeCardGesture() {
        waterIntakeCard.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(waterIntakeCardTapped))
        waterIntakeCard.addGestureRecognizer(tapGesture)
    }
    
    @objc func waterIntakeCardTapped() {
        performSegue(withIdentifier: "waterIntakeSegue", sender: self)
    }
}

// MARK: - IBActions

extension HomeViewController {
    
    @IBAction func onNotificationClose(_ sender: Any) {
        dismissNotificationView()
    }
}

// MARK: - Helpers

private extension HomeViewController {
    
    func dismissNotificationView() {
        UIView.animate(withDuration: 0.3, animations: {
            self.notificationView.alpha = 0
        }) { _ in
            self.notificationView.isHidden = true
            self.notificationView.alpha = 1
        }
    }
    
    func provideHapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
}
