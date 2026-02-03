import HealthKit
import UIKit

final class HomeViewController: UIViewController {

    // MARK: - IBOutlets
    // Header
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var greetingsLabel: UILabel!
    @IBOutlet weak var notificationView: UIView!

    // Summary Cards
    @IBOutlet weak var circularSummariesStack: UIStackView!
    @IBOutlet weak var caloriesSummaryCard: CircularProgressView!

    // Water Intake
    @IBOutlet weak var waterIntakeCard: SummaryCardView!
    @IBOutlet weak var glassValue: UILabel!
    @IBOutlet weak var glassDecrement: UIImageView!
    @IBOutlet weak var glassIncrement: UIImageView!

    // Calories
    @IBOutlet weak var caloriesCard: CircularProgressView!
    @IBOutlet weak var caloriesLabel: UILabel!

    // Steps
    @IBOutlet weak var stepsCard: CircularProgressView!
    @IBOutlet weak var stepsLabel: UILabel!

    // Glucose
    @IBOutlet weak var glucoseCard: SummaryCardView!
    @IBOutlet weak var glucoseLabel: UILabel!

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

    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleProfileUpdate),
            name: NSNotification.Name(NotificationNames.profileUpdated),
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleMealsUpdate),
            name: NSNotification.Name(NotificationNames.mealsUpdated),
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleGlucoseUpdate),
            name: NSNotification.Name(NotificationNames.glucoseUpdated),
            object: nil
        )
    }

    private func setupUI() {
        // Card corner radius
        notificationView.addRoundedCorner(
            radius: UIConstants.CornerRadius.medium
        )
        mealLogCardView.addRoundedCorner()
        symptomLogCard.addRoundedCorner()

        // header view design
        headerView.applyLiquidGlassEffect()
        headerView.layer.zPosition = 2

        // stack custom spacing
        mainStack.setCustomSpacing(
            UIConstants.Spacing.large,
            after: notificationView
        )
        mainStack.setCustomSpacing(
            UIConstants.Spacing.large,
            after: circularSummariesStack
        )
    }

    // MARK: IB Actions
    @IBAction func onNotificationClose(_ sender: Any) {
        UIView.animate(
            withDuration: 0.3,
            animations: {
                self.notificationView.alpha = 0
            }
        ) { _ in
            self.notificationView.isHidden = true
            self.notificationView.alpha = 1
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Data Loading
extension HomeViewController {

    //Refreshes all dashboard UI elements with latest data
    private func updateAllUI() {
        updateGreeting()
        updateWaterIntakeUI()
        updateGlucoseUI()
        updateCaloriesUI()
    }

    private func loadData() {
        updateAllUI()
        requestHealthKitAuthorization()
        configureSummaryCards()
    }

    private func refreshData() {
        updateAllUI()
        fetchHealthData()
    }

    private func updateGreeting() {
        let firstName = ProfileService.shared.getProfile().firstName
        greetingsLabel.text = "\(Date().greetingText), \(firstName)"
    }

    private func configureSummaryCards() {
        stepsCard.configure(
            mode: .achievement,
            progress: 0,
            thickness: HealthGoals.progressThickness
        )
        caloriesSummaryCard.configure(
            mode: .limitWarning,
            progress: 0,
            thickness: HealthGoals.progressThickness
        )
    }

    @objc private func handleProfileUpdate() {
        updateGreeting()
    }

    @objc private func handleMealsUpdate() {
        updateCaloriesUI()
    }

    private func updateCaloriesUI() {
        let stats = MealService.shared.getMealStatsByDate(on: Date())

        if let label = caloriesLabel {
            label.text = "\(stats.totalCalories)"
        }

        let progress = min(
            Double(stats.totalCalories) / Double(HealthGoals.dailyCalories),
            1.0
        )
        caloriesSummaryCard.configure(
            mode: .limitWarning,
            progress: Float(progress),
            thickness: HealthGoals.progressThickness
        )
    }

    @objc private func handleGlucoseUpdate() {
        updateGlucoseUI()
    }

    private func updateGlucoseUI() {
        let readings = GlucoseService.shared.getReadings()
        // Sort by combinedDate to ensure we get the absolute latest
        let sortedReadings = readings.sorted {
            $0.combinedDate < $1.combinedDate
        }

        if let latest = sortedReadings.last {
            glucoseLabel.text = "\(latest.value)"
        } else {
            glucoseLabel.text = "--"
        }
    }
}

// MARK: - HealthKit Integration
extension HomeViewController {
    private func requestHealthKitAuthorization() {
        guard HealthKitService.shared.isHealthKitAvailable else {
            stepsLabel.text = "N/A"
            return
        }

        HealthKitService.shared.requestAuthorization {
            [weak self] success, error in
            if success {
                self?.fetchHealthData()
            } else {
                self?.stepsLabel.text = "N/A"
                print(
                    "HealthKit authorization failed: \(error?.localizedDescription ?? "")"
                )
            }
        }
    }

    private func fetchHealthData() {
        fetchTodaySteps()
    }

    private func fetchTodaySteps() {
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

    private func updateStepsUI(steps: Int) {
        // Format steps with thousands separator
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let formattedSteps =
            formatter.string(from: NSNumber(value: steps)) ?? "\(steps)"

        stepsLabel.text = formattedSteps

        // Update progress ring based on daily goal
        let progress = min(Double(steps) / Double(HealthGoals.dailySteps), 1.0)
        stepsCard.configure(
            mode: .achievement,
            progress: Float(progress),
            thickness: HealthGoals.progressThickness
        )
    }
}

// MARK: - Water Intake
extension HomeViewController {
    private func setupWaterIntakeGestures() {
        // Enable user interaction on the increment/decrement image views
        glassIncrement.isUserInteractionEnabled = true
        glassDecrement.isUserInteractionEnabled = true

        let incrementTap = UITapGestureRecognizer(
            target: self,
            action: #selector(incrementGlassCount)
        )
        glassIncrement.addGestureRecognizer(incrementTap)

        let decrementTap = UITapGestureRecognizer(
            target: self,
            action: #selector(decrementGlassCount)
        )
        glassDecrement.addGestureRecognizer(decrementTap)
    }

    @objc private func incrementGlassCount() {
        WaterIntakeService.shared.incrementGlass()
        updateWaterIntakeUI()
        animateGlassValue()
        provideHapticFeedback()
    }

    @objc private func decrementGlassCount() {
        WaterIntakeService.shared.decrementGlass()
        updateWaterIntakeUI()
        animateGlassValue()
        provideHapticFeedback()
    }

    private func updateWaterIntakeUI() {
        let count = WaterIntakeService.shared.getGlassCount()
        glassValue.text = "\(count)"
    }

    private func animateGlassValue() {
        UIView.animate(
            withDuration: 0.1,
            animations: {
                self.glassValue.transform = CGAffineTransform(
                    scaleX: 1.2,
                    y: 1.2
                )
            }
        ) { _ in
            UIView.animate(withDuration: 0.1) {
                self.glassValue.transform = .identity
            }
        }
    }
}

// MARK: - Card Navigation
extension HomeViewController {

    private func setupGestures() {
        //Glucose
        setupCardNavigation(
            for: glucoseCard,
            action: #selector(glucoseCardTapped)
        )
        // Water Intake - Setup button gestures first
        setupWaterIntakeGestures()
        // Setup card navigation for water intake, but allow touches to pass through to buttons
        let waterIntakeTap = UITapGestureRecognizer(
            target: self,
            action: #selector(waterIntakeCardTapped)
        )
        waterIntakeTap.cancelsTouchesInView = false
        waterIntakeCard.isUserInteractionEnabled = true
        waterIntakeCard.addGestureRecognizer(waterIntakeTap)
        // Calories
        setupCardNavigation(
            for: caloriesCard,
            action: #selector(caloriesCardTapped)
        )
        // Steps
        setupCardNavigation(for: stepsCard, action: #selector(stepsCardTapped))
    }

    /// Sets up tap gesture for a card that navigates to a detail screen
    private func setupCardNavigation(for view: UIView, action: Selector) {
        view.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: action)
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func glucoseCardTapped() {
        performSegue(withIdentifier: "glucoseSegue", sender: self)
    }

    @objc private func waterIntakeCardTapped() {
        performSegue(withIdentifier: "waterIntakeSegue", sender: self)
    }

    @objc private func caloriesCardTapped() {
        performSegue(withIdentifier: "mealSegue", sender: self)
    }

    @objc private func stepsCardTapped() {
        performSegue(withIdentifier: "stepsSegue", sender: nil)
    }
}
