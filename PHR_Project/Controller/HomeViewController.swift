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

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Setup
extension HomeViewController {

    fileprivate func setupUI() {
        configureCardAppearance()
        configureHeaderAppearance()
        configureStackSpacing()
    }

    fileprivate func configureCardAppearance() {
        notificationView.addRoundedCorner(
            radius: UIConstants.CornerRadius.medium
        )
        mealLogCardView.addRoundedCorner()
        symptomLogCard.addRoundedCorner()
    }

    fileprivate func configureHeaderAppearance() {
        headerView.applyLiquidGlassEffect()
        headerView.layer.zPosition = 2
    }

    fileprivate func configureStackSpacing() {
        mainStack.setCustomSpacing(
            UIConstants.Spacing.large,
            after: notificationView
        )
        mainStack.setCustomSpacing(
            UIConstants.Spacing.large,
            after: circularSummariesStack
        )
    }

    fileprivate func setupGestures() {
        setupWaterIntakeGestures()
        setupGlucoseCardGesture()
        setupWaterIntakeCardGesture()
        setupCaloriesCardGesture()
        setupStepsCardGesture()
    }

    fileprivate func setupNotificationObservers() {
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
}

// MARK: - Data Loading
extension HomeViewController {

    fileprivate func loadData() {
        updateGreeting()
        configureSummaryCards()
        configureSummaryCards()
        updateWaterIntakeUI()
        updateGlucoseUI()
        updateCaloriesUI()
        requestHealthKitAuthorization()
        updateGlucoseUI()
        requestHealthKitAuthorization()
    }

    fileprivate func refreshData() {
        updateGreeting()
        func refreshData() {
            updateGreeting()
            updateWaterIntakeUI()
            updateGlucoseUI()
            updateCaloriesUI()
            fetchHealthData()
        }
        updateGlucoseUI()
        fetchHealthData()
    }

    fileprivate func updateGreeting() {
        let firstName = ProfileService.shared.getProfile().firstName
        let hour = Calendar.current.component(.hour, from: Date())
        let greeting: String
        switch hour {
        case 0..<12: greeting = "Good Morning"
        case 12..<17: greeting = "Good Afternoon"
        default: greeting = "Good Evening"
        }
        greetingsLabel.text = "\(greeting), \(firstName)"
    }

    fileprivate func configureSummaryCards() {
        stepsCard.configure(mode: .achievement, progress: 0, thickness: 16)
        caloriesSummaryCard.configure(
            mode: .limitWarning,
            progress: 0,
            thickness: 16
        )
    }

    @objc fileprivate func handleProfileUpdate() {
        updateGreeting()
    }

    @objc fileprivate func handleMealsUpdate() {
        updateCaloriesUI()
    }

    fileprivate func updateCaloriesUI() {
        let stats = MealService.shared.getMealStatsByDate(on: Date())

        if let label = caloriesLabel {
            label.text = "\(stats.totalCalories)"
        }

        let goal = 2000
        let progress = min(Double(stats.totalCalories) / Double(goal), 1.0)
        caloriesSummaryCard.configure(
            mode: .limitWarning,
            progress: Float(progress),
            thickness: 16
        )
    }

    @objc fileprivate func handleGlucoseUpdate() {
        updateGlucoseUI()
    }

    fileprivate func updateGlucoseUI() {
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

    /// Daily step goal for progress calculation
    fileprivate var dailyStepGoal: Int { 10000 }

    fileprivate func requestHealthKitAuthorization() {
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
                if let error = error {
                    print(
                        "HealthKit authorization failed: \(error.localizedDescription)"
                    )
                }
            }
        }
    }

    fileprivate func fetchHealthData() {
        fetchTodaySteps()
    }

    fileprivate func fetchTodaySteps() {
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

    fileprivate func updateStepsUI(steps: Int) {
        // Format steps with thousands separator
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let formattedSteps =
            formatter.string(from: NSNumber(value: steps)) ?? "\(steps)"

        stepsLabel.text = formattedSteps

        // Update progress ring based on daily goal
        let progress = min(Double(steps) / Double(dailyStepGoal), 1.0)
        stepsCard.configure(
            mode: progress >= 1.0 ? .achievement : .achievement,
            progress: Float(progress),
            thickness: 16
        )
    }
}

// MARK: - Water Intake
extension HomeViewController {
    fileprivate func setupWaterIntakeGestures() {
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

    @objc fileprivate func incrementGlassCount() {
        WaterIntakeService.shared.incrementGlass()
        updateWaterIntakeUI()
        animateGlassValue()
        provideHapticFeedback()
    }

    @objc fileprivate func decrementGlassCount() {
        WaterIntakeService.shared.decrementGlass()
        updateWaterIntakeUI()
        animateGlassValue()
        provideHapticFeedback()
    }

    fileprivate func updateWaterIntakeUI() {
        let count = WaterIntakeService.shared.getGlassCount()
        glassValue.text = "\(count)"
    }

    fileprivate func animateGlassValue() {
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

// MARK: - Glucose Card Navigation

extension HomeViewController {
    fileprivate func setupGlucoseCardGesture() {
        glucoseCard.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(glucoseCardTapped)
        )
        glucoseCard.addGestureRecognizer(tapGesture)
    }

    @objc fileprivate func glucoseCardTapped() {
        performSegue(withIdentifier: "glucoseSegue", sender: self)
    }
}

// MARK: - Water Intake Card Navigation

extension HomeViewController {
    fileprivate func setupWaterIntakeCardGesture() {
        waterIntakeCard.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(waterIntakeCardTapped)
        )
        waterIntakeCard.addGestureRecognizer(tapGesture)
    }

    @objc fileprivate func waterIntakeCardTapped() {
        performSegue(withIdentifier: "waterIntakeSegue", sender: self)
    }
}

// MARK: - Calories Card Navigation

extension HomeViewController {
    fileprivate func setupCaloriesCardGesture() {
        caloriesCard.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(caloriesCardTapped)
        )
        caloriesCard.addGestureRecognizer(tapGesture)
    }

    @objc fileprivate func caloriesCardTapped() {
        performSegue(withIdentifier: "mealSegue", sender: self)
    }
}

// MARK: - Steps Card Navigation
extension HomeViewController {
    fileprivate func setupStepsCardGesture() {
        stepsCard.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(stepsCardTapped)
        )
        stepsCard.addGestureRecognizer(tapGesture)
    }

    @objc fileprivate func stepsCardTapped() {
        performSegue(withIdentifier: "stepsSegue", sender: nil)
    }
}

// MARK: - IBActions
extension HomeViewController {
    @IBAction func onNotificationClose(_ sender: Any) {
        dismissNotificationView()
    }
}

// MARK: - Helpers
extension HomeViewController {
    fileprivate func dismissNotificationView() {
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
}
