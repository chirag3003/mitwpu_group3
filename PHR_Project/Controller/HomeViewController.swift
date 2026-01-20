//
//  HomeViewController.swift
//  PHR_Project
//
//  Created by SDC_USER on 14/11/25.
//

import UIKit
import HealthKit

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
    
    // Calories and Steps
    @IBOutlet weak var caloriesCard: CircularProgressView!
    @IBOutlet weak var stepsCard: CircularProgressView!
    @IBOutlet weak var stepsLabel: UILabel!
    
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
        setupCaloriesCardGesture()
        setupStepsCardGesture()
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
        requestHealthKitAuthorization()
    }
    
    func refreshData() {
        updateGreeting()
        updateWaterIntakeUI()
        fetchHealthData()
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

// MARK: - HealthKit Integration

private extension HomeViewController {
    
    /// Daily step goal for progress calculation
    var dailyStepGoal: Int { 10000 }
    
    func requestHealthKitAuthorization() {
        guard HealthKitService.shared.isHealthKitAvailable else {
            stepsLabel.text = "N/A"
            return
        }
        
        HealthKitService.shared.requestAuthorization { [weak self] success, error in
            if success {
                self?.fetchHealthData()
            } else {
                self?.stepsLabel.text = "N/A"
                if let error = error {
                    print("HealthKit authorization failed: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func fetchHealthData() {
        fetchTodaySteps()
    }
    
    func fetchTodaySteps() {
        HealthKitService.shared.fetchTodaySteps { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let steps):
                self.updateStepsUI(steps: steps)
            case .failure(let error):
                print("Failed to fetch steps: \(error.localizedDescription)")
                self.stepsLabel.text = "N/A"
            }
        }
    }
    
    func updateStepsUI(steps: Int) {
        // Format steps with thousands separator
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let formattedSteps = formatter.string(from: NSNumber(value: steps)) ?? "\(steps)"
        
        stepsLabel.text = formattedSteps
        
        // Update progress ring based on daily goal
        let progress = min(Double(steps) / Double(dailyStepGoal), 1.0)
        stepsSummaryCard.configure(
            mode: progress >= 1.0 ? .achievement : .achievement,
            progress: Float(progress),
            thickness: 16
        )
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

// MARK: - Calories Card Navigation

private extension HomeViewController {
    
    func setupCaloriesCardGesture() {
        caloriesCard.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(caloriesCardTapped))
        caloriesCard.addGestureRecognizer(tapGesture)
    }
    
    @objc func caloriesCardTapped() {
        performSegue(withIdentifier: "mealSegue", sender: self)
    }
}

// MARK: - Steps Card Navigation

private extension HomeViewController {
    
    func setupStepsCardGesture() {
        stepsCard.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(stepsCardTapped))
        stepsCard.addGestureRecognizer(tapGesture)
    }
    
    @objc func stepsCardTapped() {
        openAppleHealth()
    }
    
    func openAppleHealth() {
        // Apple Health URL scheme
        guard let healthURL = URL(string: "x-apple-health://") else { return }
        
        if UIApplication.shared.canOpenURL(healthURL) {
            UIApplication.shared.open(healthURL, options: [:], completionHandler: nil)
        } else {
            // Fallback: Show alert if Health app is not available
            let alert = UIAlertController(
                title: "Health App Unavailable",
                message: "The Apple Health app is not available on this device.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
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
