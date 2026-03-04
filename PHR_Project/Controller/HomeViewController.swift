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

    //Nutrients
    @IBOutlet weak var nutrientStack: UIStackView!
    @IBOutlet weak var carbsCard: SemicircularProgressView!
    @IBOutlet weak var proteinCard: SemicircularProgressView!
    @IBOutlet weak var fiberCard: SemicircularProgressView!
    @IBOutlet weak var carbsLabel: UILabel!
    @IBOutlet weak var proteinLabel: UILabel!
    @IBOutlet weak var fiberLabel: UILabel!
    
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
        
        nutrientStack.addRoundedCorner()
        mealLogCardView.addRoundedCorner()
        symptomLogCard.addRoundedCorner()
        
        carbsCard.configure(
            progress: 0.81,
            thickness: UIConstants.ProgressThickness.thin
        )
        carbsCard.addRoundedCorner()
        
        proteinCard.configure(
            progress: 0.81,
            thickness: UIConstants.ProgressThickness.thin
        )
        proteinCard.addRoundedCorner()
        
        fiberCard.configure(
            progress: 0.81,
            thickness: UIConstants.ProgressThickness.thin
        )
        fiberCard.addRoundedCorner()
       

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
        updateCarbsUI()
        updateFiberUI()
        updateProteinUI()
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
    
    private func updateCarbsUI() {
        let stats = MealService.shared.getMealStatsByDate(on: Date())
        
        if let label = carbsLabel {
            label.text = "\(stats.totalCarbs)"
        }
        let progress = min(
            Double(stats.totalCarbs) / Double(HealthGoals.dailyCarbs),
            1.0
        )
        carbsCard.configure(
            progress: Float(progress),
            thickness: UIConstants.ProgressThickness.thin
        )
    }
    
    
    private func updateProteinUI() {
        let stats = MealService.shared.getMealStatsByDate(on: Date())
        
        if let label = proteinLabel {
            label.text = "\(stats.totalProtein)"
        }
        let progress = min(
            Double(stats.totalProtein) / Double(HealthGoals.dailyProtein),
            1.0
        )
        proteinCard.configure(
            progress: Float(progress),
            thickness: UIConstants.ProgressThickness.thin
        )
    }
    
    private func updateFiberUI() {
        let stats = MealService.shared.getMealStatsByDate(on: Date())
        
        if let label = fiberLabel {
            label.text = "\(stats.totalFiber)"
        }
        let progress = min(
            Double(stats.totalFiber) / Double(HealthGoals.dailyFiber),
            1.0
        )
        fiberCard.configure(
            progress: Float(progress),
            thickness: UIConstants.ProgressThickness.thin
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
        WaterIntakeService.shared.incrementGlass { [weak self] count in
            guard let self = self else { return }
            self.updateWaterIntakeUI(with: count)
            self.animateGlassValue()
            self.provideHapticFeedback()
        }
    }

    @objc private func decrementGlassCount() {
        WaterIntakeService.shared.decrementGlass { [weak self] count in
            guard let self = self else { return }
            self.updateWaterIntakeUI(with: count)
            self.animateGlassValue()
            self.provideHapticFeedback()
        }
    }

    private func updateWaterIntakeUI() {
        WaterIntakeService.shared.fetchGlassCount { [weak self] count in
            self?.updateWaterIntakeUI(with: count)
        }
    }

    private func updateWaterIntakeUI(with count: Int) {
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

//let mealSections = ["Breakfast", "Lunch", "Snacks", "Dinner"]
//
//extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
//    
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // Only count sections that have meals logged
//        return mealSections.indices.filter { sectionIndex in
//            !MealService.shared.getMeals(forSection: sectionIndex, on: Date()).isEmpty
//        }.count
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(
//            withIdentifier: "HomeMealItemTableViewCell",
//            for: indexPath
//        ) as! HomeMealItemTableViewCell
//        
//        // Get only sections that have meals
//        let loggedSectionIndices = mealSections.indices.filter { sectionIndex in
//            !MealService.shared.getMeals(forSection: sectionIndex, on: Date()).isEmpty
//        }
//        
//        // Map indexPath.row to the actual section index
//        let actualSectionIndex = loggedSectionIndices[indexPath.row]
//        let meals = MealService.shared.getMeals(forSection: actualSectionIndex, on: Date())
//        
//        // Show the actual meal name (first meal's name in the section)
//        cell.mealName.text = meals.first?.name ?? mealSections[actualSectionIndex]
//        
//        // Sum up nutrition values
//        let totalCalories = meals.reduce(0) { $0 + $1.calories }
//        let totalCarbs    = meals.reduce(0) { $0 + $1.carbs }
//        let totalProtein  = meals.reduce(0) { $0 + $1.protein }
//        let totalFiber    = meals.reduce(0) { $0 + $1.fiber }
//        
//        cell.calories.text = "\(totalCalories) kcal"
//        cell.carbs.text    = "\(totalCarbs)g"
//        cell.protein.text  = "\(totalProtein)g"
//        cell.fiber.text    = "\(totalFiber)g"
//        
//        // Set meal image
////        if let imageName = meals.first?.image {
////            cell.mealImage.image = UIImage(named: imageName)
////        }
//        
//        return cell
//    }
//    
////    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
////        return 80
////    }
////    
////    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
////        return 12
////    }
//    
////    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
////        let spacer = UIView()
////        spacer.backgroundColor = .clear
////        return spacer
////    }
//    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//        
//        // Get only sections that have meals
//        let loggedSectionIndices = mealSections.indices.filter { sectionIndex in
//            !MealService.shared.getMeals(forSection: sectionIndex, on: Date()).isEmpty
//        }
//        
//        let actualSectionIndex = loggedSectionIndices[indexPath.row]
//        print("\(mealSections[actualSectionIndex]) tapped")
//    }
//}
