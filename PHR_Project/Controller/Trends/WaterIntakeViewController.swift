import UIKit

class WaterIntakeViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var progressView: CircularProgressView!
    @IBOutlet weak var monthName: UILabel!
    @IBOutlet weak var dateCollectionView: UICollectionView!
    
    //glass value changes
    @IBOutlet weak var glassValue: UILabel!
    @IBOutlet weak var increment: UIImageView!
    @IBOutlet weak var decrement: UIImageView!
    
    @IBOutlet weak var mlLabel: UILabel!
    //insights
    @IBOutlet weak var insight1: UIView!
    @IBOutlet weak var insight2: UIView!
    
    // MARK: - Properties
    var dates: MealDataStore = MealDataStore.shared
    var hasScrolledToToday = false
    var selectedDate: Date = Date() // Track currently selected date
    var currentCenteredIndex: Int = 15 
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup Collection View
        dateCollectionView.dataSource = self
        dateCollectionView.delegate = self
        dateCollectionView.setCollectionViewLayout(
            createDateLayout(),
            animated: true
        )
        dateCollectionView.isScrollEnabled = true
        dateCollectionView.showsVerticalScrollIndicator = false
        dateCollectionView.showsHorizontalScrollIndicator = false
        dateCollectionView.bounces = false
        
        // View Styling
        insight1.addRoundedCorner(radius: 20)
        insight2.addRoundedCorner(radius: 20)
        
        // Initial Progress Setup
        progressView.configure(mode: .achievement, progress: 0.8, thickness: UIConstants.ProgressThickness.thin)
        
        progressView.addRoundedCorner()
        setupWaterIntakeGestures()
        setupNotificationObservers()
        
        // Initialize with today's date
        updateMonthLabel(for: 15)
        updateWaterIntakeUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateWaterIntakeUI()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Auto-scroll to "Today" (Index 15) on first load
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
                
                // Initialize selected date to today
                self.currentCenteredIndex = 15
                self.updateMonthLabel(for: 15)
                self.updateWaterIntakeUI()
                
                self.hasScrolledToToday = true
            }
        }
    }
    
    // MARK: - Layout Creation
    private func createDateLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout {
            (sectionIndex, env) -> NSCollectionLayoutSection? in

            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)

            // Split width by 7 to show a week at a time
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0/7.0),
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
    
    // MARK: - UI Logic
    private func updateMonthLabel(for index: Int) {
        let calendar = Calendar.current
        let today = Date()
        
        // Offset logic assuming index 15 is current day
        let daysOffset = index - 15
        if let targetDate = calendar.date(byAdding: .day, value: daysOffset, to: today) {
            selectedDate = targetDate // Update selected date
            currentCenteredIndex = index // Track centered index
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMMM"
            monthName.text = dateFormatter.string(from: targetDate)
        }
    }
}

// MARK: - Private Logic Extension
private extension WaterIntakeViewController {
    
    func setupWaterIntakeGestures() {
        increment.isUserInteractionEnabled = true
        decrement.isUserInteractionEnabled = true
        
        increment.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(incrementGlassCount)))
        decrement.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(decrementGlassCount)))
    }
    
    func setupNotificationObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleWaterIntakeUpdate),
            name: NSNotification.Name(NotificationNames.waterIntakeUpdated),
            object: nil
        )
    }
    
    
    @objc func incrementGlassCount() {
        let calendar = Calendar.current
        guard calendar.isDateInToday(selectedDate) else {
            showPastDateAlert()
            return
        }
        // Increment for the currently selected date
        WaterIntakeService.shared.incrementGlass(for: selectedDate)
        
        // Update UI
        updateWaterIntakeUI()
        
        // Reload the cell for the current centered date
        let indexPath = IndexPath(item: currentCenteredIndex, section: 0)
        UIView.performWithoutAnimation {
            dateCollectionView.reloadItems(at: [indexPath])
        }
        
        animateGlassValue()
        provideHapticFeedback()
    }
    
    
    @objc func decrementGlassCount() {
        let calendar = Calendar.current
        guard calendar.isDateInToday(selectedDate) else {
            showPastDateAlert()
            return
        }
        // Decrement for the currently selected date
        WaterIntakeService.shared.decrementGlass(for: selectedDate)
        
        // Update UI
        updateWaterIntakeUI()
        
        // Reload the cell for the current centered date
        let indexPath = IndexPath(item: currentCenteredIndex, section: 0)
        UIView.performWithoutAnimation {
            dateCollectionView.reloadItems(at: [indexPath])
        }
        
        animateGlassValue()
        provideHapticFeedback()
    }
    func showPastDateAlert() {
        let alert = UIAlertController(
            title: "Cannot Edit Past Data",
            message: "You can only edit today's water intake. Past dates are locked.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @objc func handleWaterIntakeUpdate() {
        updateWaterIntakeUI()
    }
    
    func updateWaterIntakeUI() {
        // Get count for the currently selected date
        let count = WaterIntakeService.shared.getGlassCount(for: selectedDate)
        // Check if selected date is today
        let calendar = Calendar.current
        let isToday = calendar.isDateInToday(selectedDate)
        
        // Update label on main thread
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.glassValue.text = "\(count)"
            let currentMl = count * 250
                      let goalMl = 2500
                      self.mlLabel.text = "\(currentMl)/\(goalMl) ml"
            // Calculate progress percentage (Goal = 10 glasses)
            let progress = Float(count) / 10.0
            self.progressView.configure(
                mode: .achievement,
                progress: min(progress, 1.0),
                thickness: UIConstants.ProgressThickness.thick
            )
            // Enable/disable increment/decrement based on whether it's today
            self.increment.alpha = isToday ? 1.0 : 0.3
            self.decrement.alpha = isToday ? 1.0 : 0.3
            self.increment.isUserInteractionEnabled = isToday
            self.decrement.isUserInteractionEnabled = isToday
        }
    }
    
    func animateGlassValue() {
        // Bounce effect when count changes
        UIView.animate(withDuration: 0.1, animations: {
            self.glassValue.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.glassValue.transform = .identity
            }
        }
    }
}

// MARK: - CollectionView Protocols
extension WaterIntakeViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dates.getDays().count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CellIdentifiers.dateCell,
            for: indexPath
        ) as! DatesCollectionViewCell
        
        let date = dates.getDays()[indexPath.row]
        
        // Configure cell in water intake mode
        cell.configureCell(date: date, mode: .waterIntake)
        
        // Highlight today visually
        cell.isToday = (indexPath.row == 15)
        
        // Get fresh water intake for this date and set progress
        let waterIntake = getWaterIntakeForDate(at: indexPath.row)
        let progress = Float(waterIntake) / 10.0 // Goal is 10 glasses
        
        // Set progress
        cell.waterProgress = progress
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Scroll to selected item
        collectionView.scrollToItem(
            at: indexPath,
            at: .centeredHorizontally,
            animated: true
        )
        
        // Update selected date
        updateMonthLabel(for: indexPath.row)
        updateWaterIntakeUI()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    // MARK: - Scroll Handling
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateCenteredCell()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            updateCenteredCell()
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        updateCenteredCell()
    }
    
    private func updateCenteredCell() {
        // Calculate which cell is centered
        let centerPoint = CGPoint(
            x: dateCollectionView.contentOffset.x + dateCollectionView.bounds.width / 2,
            y: dateCollectionView.bounds.height / 2
        )
        
        if let indexPath = dateCollectionView.indexPathForItem(at: centerPoint) {
            // Select the centered cell
            dateCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
            
            // Update the selected date
            updateMonthLabel(for: indexPath.row)
            updateWaterIntakeUI()
        }
    }
    
    // MARK: - Helper Methods
    
    private func getWaterIntakeForDate(at index: Int) -> Int {
        let calendar = Calendar.current
        let today = Date()
        let daysOffset = index - 15
        
        guard let targetDate = calendar.date(byAdding: .day, value: daysOffset, to: today) else {
            return 0
        }
        
        // Get water intake count for the target date from service
        return WaterIntakeService.shared.getGlassCount(for: targetDate)
    }
}

