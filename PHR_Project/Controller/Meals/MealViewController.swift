import UIKit

class SectionBackground: UICollectionReusableView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.tertiarySystemBackground
        layer.cornerRadius = 16
        clipsToBounds = true

    }
    required init?(coder: NSCoder) { fatalError() }
}

class MealViewController: UIViewController, FamilyMemberDataScreen {

    // MARK: IB OUTLETS
    @IBOutlet weak var caloriebgCard: UIView!

    @IBOutlet weak var monthName: UILabel!

    //Nutrition
    @IBOutlet weak var fiberLabel: UILabel!
    @IBOutlet weak var proteinLabel: UILabel!
    @IBOutlet weak var carbsLabel: UILabel!
    @IBOutlet weak var caloriesLabel: UILabel!

    //Tips
    @IBOutlet weak var tipOneLabel: UILabel!
    @IBOutlet weak var tipTwoLabel: UILabel!
    @IBOutlet weak var tipThreeLabel: UILabel!
    @IBOutlet weak var tipOne: UIView!
    @IBOutlet weak var tipTwo: UIView!
    @IBOutlet weak var tipThree: UIView!

    //Insight
    @IBOutlet weak var insightOne: UIView!
    @IBOutlet weak var insightOneLabel: UILabel!
    @IBOutlet weak var insightTwo: UIView!
    @IBOutlet weak var insightTwoLabel: UILabel!

    //Semicircular Progress cards
    @IBOutlet weak var fiberProgress: SemicircularProgressView!
    @IBOutlet weak var proteinProgress: SemicircularProgressView!
    @IBOutlet weak var carbsProgress: SemicircularProgressView!

    //Circular Progress card
    @IBOutlet weak var calorieProgressView: CircularProgressView!

    //Collection Views
    @IBOutlet weak var mealCollectionView: MealItemCollectionView!
    @IBOutlet weak var dateCollectionView: UICollectionView!

    // MARK: Properties
    var dates: MealDataStore = MealDataStore.shared
    var selectedDate: Date = Date()
    var familyMember: FamilyMember?
    var hasScrolledToToday = false

    let sectionTitles = ["Breakfast", "Lunch", "Snacks", "Dinner"]
    
    // Insights data from API
    private var mealInsights: MealInsightsResponse?
    
    // Placeholder text for loading state
    private let defaultTips: [String] = [
        "Loading Tips...",
        "Loading Tips...",
        "Loading Tips...",
    ]
    private let defaultInsights: [String] = [
        "Loading Insights...",
        "Loading Insights...",
    ]

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupDateCollectionView()
        setupMealCollectionView()
        
        setupProgressViews()
        setupInsightCards()
        setupTipCards()
        
        setupNotifications()
        updateTitle()
        updateMonthLabel(for: 15)
        updateStats()
        
        // Fetch AI insights from API
        fetchMealInsights()
    }

    // Refresh meal list when returning to screen
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mealCollectionView.reloadData()
    }

    // Auto-scroll to today's date after layout is ready
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollToTodayIfNeeded()
    }

    // MARK: Setup

    //Configure date picker collection view
    private func setupDateCollectionView() {
        dateCollectionView.dataSource = self
        dateCollectionView.delegate = self
        dateCollectionView.setCollectionViewLayout(
            createDateLayout(),
            animated: true
        )
    }

    //Register cells and configure meal list layout
    private func setupMealCollectionView() {
        let mealNib = UINib(nibName: "MealItemCollectionViewCell", bundle: nil)
        mealCollectionView.register(
            mealNib,
            forCellWithReuseIdentifier: "MealCell"
        )
        mealCollectionView.register(
            NoMealsCollectionViewCell.self,
            forCellWithReuseIdentifier: "NoMealsCell"
        )
        mealCollectionView.collectionViewLayout = createMealLayout()
        mealCollectionView.dataSource = self
        mealCollectionView.delegate = self
    }

    //Style and configure all nutrition progress indicators
    private func setupProgressViews() {
        caloriebgCard.addRoundedCorner(radius: 20)

        calorieProgressView.configure(
            mode: .limitWarning,
            progress: 0.49,
            thickness: UIConstants.ProgressThickness.thick
        )

        carbsProgress.configure(
            progress: 0.81,
            thickness: UIConstants.ProgressThickness.thin
        )
        carbsProgress.addRoundedCorner()

        proteinProgress.configure(
            progress: 0.66,
            thickness: UIConstants.ProgressThickness.thin
        )
        proteinProgress.addRoundedCorner()

        fiberProgress.configure(
            progress: 0.71,
            thickness: UIConstants.ProgressThickness.thin
        )
        fiberProgress.addRoundedCorner()
    }

    //Populate insight cards with text
    private func setupInsightCards() {
        insightOne.addRoundedCorner(radius: 20)
        insightOneLabel.text = defaultInsights[0]

        insightTwo.addRoundedCorner(radius: 20)
        insightTwoLabel.text = defaultInsights[1]
    }

    //Populate tip cards with suggestions
    private func setupTipCards() {
        tipOne.addRoundedCorner(radius: 20)
        tipOneLabel.text = defaultTips[0]

        tipTwo.addRoundedCorner(radius: 20)
        tipTwoLabel.text = defaultTips[1]

        tipThree.addRoundedCorner(radius: 20)
        tipThreeLabel.text = defaultTips[2]
    }
    
    // MARK: - Insights API
    
    //Fetch meal insights from API and update UI
    private func fetchMealInsights() {
        InsightsService.shared.fetchMealInsights { [weak self] response in
            guard let self = self, let insights = response else { return }
            
            self.mealInsights = insights
            self.updateInsightsUI(with: insights)
        }
    }
    
    //Update insight and tip cards with API data
    private func updateInsightsUI(with response: MealInsightsResponse) {
        // Update insight cards
        if response.insights.count >= 1 {
            insightOneLabel.text = response.insights[0].description
            insightOne.backgroundColor = response.insights[0].type.color.withAlphaComponent(0.15)
        }
        if response.insights.count >= 2 {
            insightTwoLabel.text = response.insights[1].description
            insightTwo.backgroundColor = response.insights[1].type.color.withAlphaComponent(0.15)
        }
        
        // Update tip cards
        if response.tips.count >= 1 {
            tipOneLabel.text = response.tips[0].description
            tipOne.backgroundColor = response.tips[0].priority.color.withAlphaComponent(0.15)
        }
        if response.tips.count >= 2 {
            tipTwoLabel.text = response.tips[1].description
            tipTwo.backgroundColor = response.tips[1].priority.color.withAlphaComponent(0.15)
        }
        if response.tips.count >= 3 {
            tipThreeLabel.text = response.tips[2].description
            tipThree.backgroundColor = response.tips[2].priority.color.withAlphaComponent(0.15)
        }
    }

    //Listen for meal changes from other screens
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(refreshData),
            name: NSNotification.Name(NotificationNames.mealsUpdated),
            object: nil
        )
    }

    //Set screen title based on family member or default
    private func updateTitle() {
        if let member = familyMember {
            self.title = "\(member.name)'s Meal Logs"
        } else {
            self.title = "Meal Logs"
        }
    }

    // MARK: Data Updates

    //Reload UI when meals change
    @objc func refreshData() {
        DispatchQueue.main.async {
            self.mealCollectionView.reloadData()
            self.updateStats()
        }
    }

    //Calculate and display nutrition totals for selected date
    func updateStats() {
        let stats = MealService.shared.getMealStatsByDate(on: selectedDate)

        // Update labels
        caloriesLabel.text = "\(stats.totalCalories)"
        carbsLabel.text = "\(stats.totalCarbs)"
        proteinLabel.text = "\(stats.totalProtein)"
        fiberLabel.text = "\(stats.totalFiber)"

        // Goals
        let calorieGoal: Double = 2000
        let carbsGoal: Double = 220
        let proteinGoal: Double = 90
        let fiberGoal: Double = 35

        // Update progress
        calorieProgressView.configure(
            mode: .limitWarning,
            progress: Float(
                min(Double(stats.totalCalories) / calorieGoal, 1.0)
            ),
            thickness: UIConstants.ProgressThickness.thick
        )

        carbsProgress.configure(
            progress: Float(min(Double(stats.totalCarbs) / carbsGoal, 1.0)),
            thickness: UIConstants.ProgressThickness.thin
        )

        proteinProgress.configure(
            progress: Float(min(Double(stats.totalProtein) / proteinGoal, 1.0)),
            thickness: UIConstants.ProgressThickness.thin
        )

        fiberProgress.configure(
            progress: Float(min(Double(stats.totalFiber) / fiberGoal, 1.0)),
            thickness: UIConstants.ProgressThickness.thin
        )
    }

    //Update month header based on date index
    private func updateMonthLabel(for index: Int) {
        let calendar = Calendar.current
        let today = Date()
        let daysOffset = index - 15

        if let targetDate = calendar.date(
            byAdding: .day,
            value: daysOffset,
            to: today
        ) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMMM"
            monthName.text = dateFormatter.string(from: targetDate)
        }
    }

    // MARK: Scroll Behavior

    //Scroll to today and highlight it on first load
    private func scrollToTodayIfNeeded() {
        if !hasScrolledToToday && dates.getDays().count > 0 {
            dateCollectionView.layoutIfNeeded()
            let todayIndex = IndexPath(item: 15, section: 0)

            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }

                self.dateCollectionView.scrollToItem(
                    at: todayIndex,
                    at: .centeredHorizontally,
                    animated: false
                )

                self.dateCollectionView.selectItem(
                    at: todayIndex,
                    animated: false,
                    scrollPosition: .centeredHorizontally
                )

                self.hasScrolledToToday = true
            }
        }
    }

    // MARK: Layouts

    //Build horizontal scrolling date picker layout
    private func createDateLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout {
            (sectionIndex, env) -> NSCollectionLayoutSection? in
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(
                top: 8,
                leading: 8,
                bottom: 8,
                trailing: 8
            )

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0 / 7.0),
                heightDimension: .absolute(100)
            )
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize,
                subitems: [item]
            )

            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .groupPagingCentered

            return section
        }
    }

    //Build sectioned meal list with swipe actions and backgrounds
    private func createMealLayout() -> UICollectionViewLayout {
        var config = UICollectionLayoutListConfiguration(
            appearance: .insetGrouped
        )
        config.headerMode = .supplementary
        config.headerTopPadding = UIConstants.Spacing.medium
        config.showsSeparators = true
        config.backgroundColor = .clear

        // Swipe to delete
        config.trailingSwipeActionsConfigurationProvider = { indexPath in
            let deleteAction = UIContextualAction(
                style: .destructive,
                title: "Delete"
            ) { action, view, completion in
                let mealsInSection = MealService.shared.getMeals(
                    forSection: indexPath.section
                )
                let mealToDelete = mealsInSection[indexPath.row]
                MealService.shared.deleteMeal(mealToDelete)
                completion(true)
            }
            deleteAction.backgroundColor = .systemRed
            return UISwipeActionsConfiguration(actions: [deleteAction])
        }

        let layout = UICollectionViewCompositionalLayout { sectionIndex, env in
            let section = NSCollectionLayoutSection.list(
                using: config,
                layoutEnvironment: env
            )

            section.contentInsets = NSDirectionalEdgeInsets(
                top: UIConstants.Padding.medium,
                leading: 0,
                bottom: UIConstants.Padding.medium,
                trailing: 0
            )

            let background = NSCollectionLayoutDecorationItem.background(
                elementKind: "section-background"
            )
            background.contentInsets = NSDirectionalEdgeInsets(
                top: UIConstants.Spacing.extraSmall,
                leading: 0,
                bottom: UIConstants.Spacing.extraSmall,
                trailing: 0
            )
            section.decorationItems = [background]

            return section
        }

        layout.register(
            SectionBackground.self,
            forDecorationViewOfKind: "section-background"
        )
        return layout
    }
}

// MARK: - Collection View

extension MealViewController: UICollectionViewDataSource,
    UICollectionViewDelegate
{

    //Return number of sections (4 meal types or 1 for dates)
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView == mealCollectionView {
            return sectionTitles.count
        }
        return 1
    }

    //Return item count per section
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        if collectionView == dateCollectionView {
            return dates.getDays().count
        }

        let count = MealService.shared.getMeals(
            forSection: section,
            on: selectedDate
        ).count
        return count == 0 ? 1 : count
    }

    //Configure and return cells for dates or meals
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {

        // Date cells
        if collectionView == dateCollectionView {
            let cell =
                collectionView.dequeueReusableCell(
                    withReuseIdentifier: CellIdentifiers.dateCell,
                    for: indexPath
                ) as! DatesCollectionViewCell

            let date = dates.getDays()[indexPath.row]
            cell.configureCell(date: date)
            cell.isToday = (indexPath.row == 15)

            return cell
        }

        // Meal cells
        let mealsInSection = MealService.shared.getMeals(
            forSection: indexPath.section,
            on: selectedDate
        )

        if mealsInSection.isEmpty {
            let cell =
                collectionView.dequeueReusableCell(
                    withReuseIdentifier: "NoMealsCell",
                    for: indexPath
                ) as! NoMealsCollectionViewCell
            return cell
        }

        let cell =
            collectionView.dequeueReusableCell(
                withReuseIdentifier: CellIdentifiers.mealCell,
                for: indexPath
            ) as! MealItemCollectionViewCell
        let meal = mealsInSection[indexPath.row]
        cell.setup(with: meal)
        return cell
    }

    //Handle date selection and update UI
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        if collectionView == dateCollectionView {
            collectionView.scrollToItem(
                at: indexPath,
                at: .centeredHorizontally,
                animated: true
            )
            updateMonthLabel(for: indexPath.row)

            // Update selected date
            let daysOffset = indexPath.row - 15
            if let date = Calendar.current.date(
                byAdding: .day,
                value: daysOffset,
                to: Date()
            ) {
                selectedDate = date
                mealCollectionView.reloadData()
                updateStats()
            }
        }
    }

    //Provide section headers for meal types
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        let header =
            collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: CellIdentifiers.sectionHeader,
                for: indexPath
            ) as! MealSectionHeaderView

        header.sectionLabel.text = sectionTitles[indexPath.section]
        return header
    }
}

// MARK: - Empty State Cell

class NoMealsCollectionViewCell: UICollectionViewCell {
    let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //Center the placeholder text
    private func setupView() {
        label.text = "No meals logged yet"
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }
}

// MARK: - Camera Delegate

extension MealViewController: CustomCameraDelegate {

    //Open camera for meal photo
    @IBAction func addMealCamera(_ sender: Any) {
        let customCameraVC = CustomCameraViewController()
        customCameraVC.delegate = self
        customCameraVC.modalPresentationStyle = .fullScreen
        present(customCameraVC, animated: true)
    }

    //Process captured meal image with AI
    func didCaptureImage(_ image: UIImage) {
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }

            self.showLoader(true)

            MealService.shared.analyzeMeal(image: image) { [weak self] result in
                guard let self = self else { return }

                self.showLoader(false)

                switch result {
                case .success(let meal):
                    print("Analysis complete: \(meal.name)")
                    self.mealCollectionView.reloadData()
                    self.showAlert(
                        title: "Success",
                        message: "Added \(meal.name)!"
                    )

                case .failure(let error):
                    print("Analysis failed: \(error)")
                    self.showAlert(
                        title: "Analysis Failed",
                        message: error.localizedDescription
                    )
                }
            }
        }
    }

    //Show manual entry screen instead of camera
    func didTapManuallyLog() {
        print("User chose to manually log")
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }

            let storyboard = UIStoryboard(name: "Meals", bundle: nil)
            let manualVC = storyboard.instantiateViewController(
                withIdentifier: "AddMealScreenNav"
            )
            manualVC.modalPresentationStyle = .pageSheet
            self.present(manualVC, animated: true, completion: nil)
        }
    }
}
