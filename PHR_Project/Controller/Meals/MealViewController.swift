import UIKit

class SectionBackground: UICollectionReusableView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.secondarySystemBackground
        layer.cornerRadius = 16
        clipsToBounds = true
        
    }
    required init?(coder: NSCoder) { fatalError() }
}

class MealViewController: UIViewController {

    @IBOutlet weak var monthName: UILabel!
    
    @IBOutlet weak var tipOne: UIView!
    @IBOutlet weak var tipTwo: UIView!
    @IBOutlet weak var tipThree: UIView!
    @IBOutlet weak var insightOne: UIView!
    
    @IBOutlet weak var insightTwo: UIView!
    @IBOutlet weak var fiberProgress: SemicircularProgressView!
    @IBOutlet weak var proteinProgress: SemicircularProgressView!
    @IBOutlet weak var carbsProgress: SemicircularProgressView!
    @IBOutlet weak var calorieProgressView: CircularProgressView!
    @IBOutlet weak var mealCollectionView: MealItemCollectionView!
    @IBOutlet weak var dateCollectionView: UICollectionView!

    var dates: MealDataStore = MealDataStore.shared
    var selectedDate: Date = Date()
    
    var hasScrolledToToday = false
    
    let sectionTitles = ["Breakfast", "Lunch", "Dinner"]

    override func viewDidLoad() {
        super.viewDidLoad()

        dateCollectionView.dataSource = self
        dateCollectionView.delegate = self
        dateCollectionView.setCollectionViewLayout(
            createDateLayout(),
            animated: true
        )
        
        updateMonthLabel(for: 15)
        
        calorieProgressView.configure(mode:.limitWarning ,progress: 0.49, thickness: UIConstants.ProgressThickness.thick)
        
        carbsProgress.configure(progress: 0.81, thickness: UIConstants.ProgressThickness.thin)
        carbsProgress.addRoundedCorner()
        carbsProgress.addDropShadow()
        
        proteinProgress.configure(progress: 0.66, thickness: UIConstants.ProgressThickness.thin)
        proteinProgress.addRoundedCorner()
        proteinProgress.addDropShadow()
        
        fiberProgress.configure(progress: 0.71, thickness: UIConstants.ProgressThickness.thin)
        fiberProgress.addRoundedCorner()
        fiberProgress.addDropShadow()
        
        insightOne.addRoundedCorner(radius: 20)
        insightTwo.addRoundedCorner(radius: 20)
        
        tipOne.addRoundedCorner(radius: 20)
        tipTwo.addRoundedCorner(radius: 20)
        tipThree.addRoundedCorner(radius: 20)
        
        
        
        setupMealCollectionView()
        
        NotificationCenter.default.addObserver(
                    self,
                    selector: #selector(refreshData),
                    name: NSNotification.Name(NotificationNames.mealsUpdated),
                    object: nil
        )

    }
    
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            mealCollectionView.reloadData()
        }
    
    @objc func refreshData() {
            DispatchQueue.main.async {
                self.mealCollectionView.reloadData()
            }
        }
    
    //To align the today's date to the center of the scroll
    override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            
            // Check if we have already scrolled and if we have data
            if !hasScrolledToToday && dates.getDays().count > 0 {
                
                // 1. FORCE the collection view to calculate cell positions right now
                dateCollectionView.layoutIfNeeded()
                
                // 2. Define the index for "Today" (Index 15)
                let todayIndex = IndexPath(item: 15, section: 0)
                
                // 3. Perform the scroll on the main thread to ensure it happens after the visual pass
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    
                    self.dateCollectionView.scrollToItem(
                        at: todayIndex,
                        at: .centeredHorizontally,
                        animated: false
                    )
                    
                    // 4. Select the item visually (highlighting the blue circle)
                    self.dateCollectionView.selectItem(
                        at: todayIndex,
                        animated: false,
                        scrollPosition: .centeredHorizontally
                    )
                    
                    self.hasScrolledToToday = true
                }
            }
        }
    
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

                // 2. Group
                // Absolute height 150 ensures enough space for Circle + Text
                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0/7.0),
                    heightDimension: .absolute(100)
                )

                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: groupSize,
                    subitems: [item]
                    //count: 7  // This divides the screen width by 7 automatically
                )
                // 3. Section
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .groupPagingCentered

                return section
            }
    }
    
    private func updateMonthLabel(for index: Int) {
        let selectedDate = dates.getDays()[index]
        
        // Extract month from the CalendarDay
        // Assuming CalendarDay has a date property or you can derive it
        let calendar = Calendar.current
        let today = Date()
        
        // Calculate the date based on index (assuming index 15 is today)
        let daysOffset = index - 15
        if let targetDate = calendar.date(byAdding: .day, value: daysOffset, to: today) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMMM" // Full month name
            monthName.text = dateFormatter.string(from: targetDate)
        }
    }

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

    private func createMealLayout() -> UICollectionViewLayout {
            var config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
            config.headerMode = .supplementary
            config.headerTopPadding = UIConstants.Spacing.medium
            config.showsSeparators = true
            config.backgroundColor = .clear
        
        config.trailingSwipeActionsConfigurationProvider = { [weak self] indexPath in
            let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { action, view, completion in
                
                let mealsInSection = MealService.shared.getMeals(forSection: indexPath.section, on: self?.selectedDate ?? Date())
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

            // Register the decoration view
            layout.register(
                SectionBackground.self,
                forDecorationViewOfKind: "section-background"
            )

            return layout
        }
}

extension MealViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        if collectionView == dateCollectionView {
            return dates.getDays().count
        }
        
        let count = MealService.shared.getMeals(forSection: section, on: selectedDate).count
        
        return count == 0 ? 1 : count
        
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if collectionView == dateCollectionView {
            let cell =
                collectionView.dequeueReusableCell(
                    withReuseIdentifier: CellIdentifiers.dateCell,
                    for: indexPath
                ) as! DatesCollectionViewCell

            let date = dates.getDays()[indexPath.row]
            cell.configureCell(date: date)
            
            if indexPath.row == 15 {
                cell.isToday = true
            } else {
                cell.isToday = false
            }
            

            return cell
        }

        let mealsInSection = MealService.shared.getMeals(forSection: indexPath.section, on: selectedDate)
                
                // 1. If empty, show the "No Meals" placeholder
        if mealsInSection.isEmpty {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NoMealsCell", for: indexPath) as! NoMealsCollectionViewCell
                    return cell
        }
                
                // 2. If not empty, show the actual meal
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifiers.mealCell, for: indexPath) as! MealItemCollectionViewCell
        let meal = mealsInSection[indexPath.row]
        cell.setup(with: meal)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == dateCollectionView {
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            
            // Calculate selected date
            // Index 15 is today (offset 0)
            let daysOffset = indexPath.row - 15
            if let date = Calendar.current.date(byAdding: .day, value: daysOffset, to: Date()) {
                selectedDate = date
                updateMonthLabel(for: indexPath.row)
                mealCollectionView.reloadData()
            }
        }
        
        let selectedDay = dates.getDays()[indexPath.row]
        print("Selected: \(selectedDay)")
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView == mealCollectionView {
            return sectionTitles.count
        }
        return 1
    }

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

class NoMealsCollectionViewCell: UICollectionViewCell {
    let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        label.text = "No meals logged yet"
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}

extension MealViewController: CustomCameraDelegate {
    
    
    @IBAction func addMealCamera(_ sender: Any) {
        // Create the custom camera VC
        let customCameraVC = CustomCameraViewController()
        
        // Set the delegate to 'self' so we get the results back
        customCameraVC.delegate = self
        
        // Present it full screen
        customCameraVC.modalPresentationStyle = .fullScreen
        present(customCameraVC, animated: true)
    }
    
    
    func didCaptureImage(_ image: UIImage) {
        print("Custom camera took a picture!")
        
        // Show loading indicator
        let alert = UIAlertController(title: "Analyzing...", message: "Please wait while we analyze your food.", preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = .medium
        loadingIndicator.startAnimating()
        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: nil)
        
        MealService.shared.analyzeMeal(image: image) { [weak self] result in
            DispatchQueue.main.async {
                self?.dismiss(animated: true) {
                    guard let self = self else { return }
                    switch result {
                    case .success(let meal):
                        print("Analysis complete: \(meal.name)")
                        // Refresh the collection view to show the new meal
                        self.mealCollectionView.reloadData()
                        
                        // Optional: Navigate to detail view or show success
                        // For now, just reload is enough as per requirement
                        
                    case .failure(let error):
                        print("Analysis failed: \(error)")
                        let errorAlert = UIAlertController(title: "Analysis Failed", message: error.localizedDescription, preferredStyle: .alert)
                        errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(errorAlert, animated: true)
                    }
                }
            }
        }
    }
    
    func didTapManuallyLog() {
        print("User chose to manually log")
        dismiss(animated: true) { [weak self] in
            
            // 2. ONLY after the camera is gone, try to present the new screen
            guard let self = self else { return }
            
            let storyboard = UIStoryboard(name: "Meals", bundle: nil)
            let manualVC = storyboard.instantiateViewController(withIdentifier: "AddMealScreenNav")
            manualVC.modalPresentationStyle = .pageSheet
            self.present(manualVC, animated: true, completion: nil)
        }
    }
}
