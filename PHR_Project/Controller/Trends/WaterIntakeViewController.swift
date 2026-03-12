import UIKit

class WaterIntakeViewController: UIViewController, FamilyMemberDataScreen,
    SharedWriteAccessReceiving
{
    var familyMember: FamilyMember?

    // MARK: - Outlets
    @IBOutlet weak var progressView: CircularProgressView!
    @IBOutlet weak var monthName: UILabel!
    @IBOutlet weak var outOfGlassesLabel: UILabel!
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
    var selectedDate: Date = Date()  // Track currently selected date
    var currentCenteredIndex: Int = 15
    private var sharedWaterRecords: [WaterRecord] = []
    private var waterInsights: WaterInsightsResponse?
    var canEditSharedData = false

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        if familyMember != nil {
            self.title = "\(familyMember!.name)'s Water Intake"
        } else {
            self.title = "Water Intake"
        }

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
        progressView.configure(
            mode: .achievement,
            progress: 0.0,
            thickness: UIConstants.ProgressThickness.thick
        )

        progressView.addRoundedCorner()
        setupWaterIntakeGestures()
        setupNotificationObservers()

        // Initialize with today's date
        updateMonthLabel(for: 15)
        updateWaterIntakeUI()
        fetchWaterInsights()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateWaterIntakeUI()
        dateCollectionView.reloadData()
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
            item.contentInsets = NSDirectionalEdgeInsets(
                top: 8,
                leading: 8,
                bottom: 8,
                trailing: 8
            )

            // Split width by 7 to show a week at a time
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

    // MARK: - UI Logic
    private func updateMonthLabel(for index: Int) {
        let calendar = Calendar.current
        let today = Date()

        // Offset logic assuming index 15 is current day
        let daysOffset = index - 15
        if let targetDate = calendar.date(
            byAdding: .day,
            value: daysOffset,
            to: today
        ) {
            selectedDate = targetDate  // Update selected date
            currentCenteredIndex = index  // Track centered index
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMMM"
            monthName.text = dateFormatter.string(from: targetDate)
        }
    }
}

// MARK: - Private Logic Extension
extension WaterIntakeViewController {

    fileprivate func setupWaterIntakeGestures() {
        increment.isUserInteractionEnabled = true
        decrement.isUserInteractionEnabled = true

        increment.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(incrementGlassCount)
            )
        )
        decrement.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(decrementGlassCount)
            )
        )
    }

    fileprivate func setupNotificationObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleWaterIntakeUpdate),
            name: NSNotification.Name(NotificationNames.waterIntakeUpdated),
            object: nil
        )
    }

    @objc fileprivate func incrementGlassCount() {
        if familyMember != nil && !canEditSharedData { return }
        let calendar = Calendar.current
        guard calendar.isDateInToday(selectedDate) else {
            showPastDateAlert()
            return
        }
        if let member = familyMember {
            updateSharedWater(for: member, delta: 1)
            return
        }
        WaterIntakeService.shared.incrementGlass(for: selectedDate) {
            [weak self] _ in
            guard let self = self else { return }
            self.reloadVisibleCells()
            self.updateWaterIntakeUI()
            self.animateGlassValue()
            self.provideHapticFeedback()
        }
    }

    @objc fileprivate func decrementGlassCount() {
        if familyMember != nil && !canEditSharedData { return }
        let calendar = Calendar.current
        guard calendar.isDateInToday(selectedDate) else {
            showPastDateAlert()
            return
        }
        if let member = familyMember {
            updateSharedWater(for: member, delta: -1)
            return
        }
        WaterIntakeService.shared.decrementGlass(for: selectedDate) {
            [weak self] _ in
            guard let self = self else { return }
            self.updateWaterIntakeUI()
            self.reloadVisibleCells()

            let indexPath = IndexPath(
                item: self.currentCenteredIndex,
                section: 0
            )
            UIView.performWithoutAnimation {
                self.dateCollectionView.reloadItems(at: [indexPath])
            }

            self.animateGlassValue()
            self.provideHapticFeedback()
        }
    }

    fileprivate func reloadVisibleCells() {
        // Reload all visible cells without animation to prevent visual glitches
        UIView.performWithoutAnimation {
            if let visibleIndexPaths = dateCollectionView
                .indexPathsForVisibleItems as? [IndexPath],
                !visibleIndexPaths.isEmpty
            {
                dateCollectionView.reloadItems(at: visibleIndexPaths)
            }
        }
    }

    fileprivate func showPastDateAlert() {
        let alert = UIAlertController(
            title: "Cannot Edit Past Data",
            message:
                "You can only edit today's water intake. Past dates are locked.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    @objc fileprivate func handleWaterIntakeUpdate() {
        updateWaterIntakeUI()
    }

    fileprivate func updateWaterIntakeUI() {
        let calendar = Calendar.current
        let isToday = calendar.isDateInToday(selectedDate)

        if let member = familyMember {
            fetchSharedWaterIfNeeded(for: member) { [weak self] count in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.updateWaterUI(count: count, isToday: isToday)
                }
            }
        } else {
            WaterIntakeService.shared.fetchGlassCount(for: selectedDate) {
                [weak self] count in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.updateWaterUI(count: count, isToday: isToday)
                }
            }
        }
    }

    private func updateWaterUI(count: Int, isToday: Bool) {
        // Fetch dynamic target
        let savedCount = UserDefaults.standard.integer(
            forKey: "targetWaterGlasses"
        )
        let targetGlasses = savedCount > 0 ? savedCount : 10
        outOfGlassesLabel.text = "Out of \(targetGlasses) glasses"
        glassValue.text = "\(count)"

        // Dynamically calculate goal ml (assuming 250ml per glass)
        let currentMl = count * 250
        let goalMl = targetGlasses * 250
        mlLabel.text = "\(currentMl)/\(goalMl) ml"

        // Dynamically calculate progress
        let progress = Float(count) / Float(targetGlasses)
        progressView.setProgress(to: min(progress, 1.0), animated: true)

        let isEditable =
            (familyMember == nil && isToday)
            || (familyMember != nil && canEditSharedData && isToday)
        increment.alpha = isEditable ? 1.0 : 0.3
        decrement.alpha = isEditable ? 1.0 : 0.3
        increment.isUserInteractionEnabled = isEditable
        decrement.isUserInteractionEnabled = isEditable
    }

    private func fetchSharedWaterIfNeeded(
        for member: FamilyMember,
        completion: @escaping (Int) -> Void
    ) {
        SharedDataService.shared.fetchWater(for: member.userId) {
            [weak self] result in
            switch result {
            case .success(let records):
                self?.sharedWaterRecords = records
                let count = self?.countForSelectedDate(from: records) ?? 0
                completion(count)
            case .failure(let error):
                print("Error fetching shared water: \(error)")
                completion(0)
            }
        }
    }

    private func countForSelectedDate(from records: [WaterRecord]) -> Int {
        let calendar = Calendar.current
        for record in records {
            if calendar.isDate(record.dateRecorded, inSameDayAs: selectedDate) {
                return record.glasses
            }
        }
        return 0
    }

    private func updateSharedWater(for member: FamilyMember, delta: Int) {
        SharedDataService.shared.fetchWater(for: member.userId) {
            [weak self] result in
            switch result {
            case .success(let records):
                let current = self?.countForSelectedDate(from: records) ?? 0

                // Use target instead of hardcoded 10
                let savedCount = UserDefaults.standard.integer(
                    forKey: "targetWaterGlasses"
                )
                let targetGlasses = savedCount > 0 ? savedCount : 10
                let newCount = max(min(current + delta, targetGlasses), 0)

                SharedDataService.shared.upsertWater(
                    for: member.userId,
                    dateRecorded: self?.selectedDate ?? Date(),
                    glasses: newCount
                ) { [weak self] result in
                    switch result {
                    case .success:
                        self?.updateWaterIntakeUI()
                        self?.reloadVisibleCells()
                        self?.animateGlassValue()
                        self?.provideHapticFeedback()
                    case .failure(let error):
                        print("Error updating shared water: \(error)")
                    }
                }
            case .failure(let error):
                print("Error fetching shared water: \(error)")
            }
        }
    }

    private func fetchWaterInsights() {
        if let member = familyMember {
            InsightsService.shared.fetchSharedWaterInsights(
                userId: member.userId
            ) {
                [weak self] response in
                guard let self = self, let insights = response else { return }
                self.waterInsights = insights
                self.updateInsightsUI(with: insights)
            }
            return
        }

        InsightsService.shared.fetchWaterInsights { [weak self] response in
            guard let self = self, let insights = response else { return }
            self.waterInsights = insights
            self.updateInsightsUI(with: insights)
        }
    }

    private func updateInsightsUI(with response: WaterInsightsResponse) {
        if response.insights.count >= 1 {
            let label = insight1.subviews.compactMap { $0 as? UILabel }.first
            label?.text = response.insights[0].description
            insight1.backgroundColor = response.insights[0].type.color
                .withAlphaComponent(0.15)
        }
        if response.insights.count >= 2 {
            let label = insight2.subviews.compactMap { $0 as? UILabel }.first
            label?.text = response.insights[1].description
            insight2.backgroundColor = response.insights[1].type.color
                .withAlphaComponent(0.15)
        }
    }

    fileprivate func animateGlassValue() {
        // Bounce effect when count changes
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

// MARK: - CollectionView Protocols
extension WaterIntakeViewController: UICollectionViewDataSource,
    UICollectionViewDelegate
{

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return dates.getDays().count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell =
            collectionView.dequeueReusableCell(
                withReuseIdentifier: CellIdentifiers.dateCell,
                for: indexPath
            ) as! DatesCollectionViewCell

        let date = dates.getDays()[indexPath.row]

        // Configure cell in water intake mode
        cell.configureCell(date: date, mode: .waterIntake)

        // Highlight today visually
        cell.isToday = (indexPath.row == 15)

        cell.waterProgress = 0

        let targetDate = getDateForIndex(indexPath.row)
        if let member = familyMember {
            SharedDataService.shared.fetchWater(for: member.userId) {
                [weak cell, weak collectionView] result in
                let count: Int
                switch result {
                case .success(let records):
                    let calendar = Calendar.current
                    count =
                        records.first(where: {
                            calendar.isDate(
                                $0.dateRecorded,
                                inSameDayAs: targetDate
                            )
                        })?.glasses ?? 0
                case .failure(let error):
                    print("Error fetching shared water: \(error)")
                    count = 0
                }

                let savedCount = UserDefaults.standard.integer(
                    forKey: "targetWaterGlasses"
                )
                let targetGlasses = savedCount > 0 ? savedCount : 10
                let progress = Float(count) / Float(targetGlasses)
                DispatchQueue.main.async {
                    guard let cell = cell,
                        let collectionView = collectionView,
                        collectionView.indexPath(for: cell) == indexPath
                    else {
                        return
                    }
                    cell.waterProgress = progress
                }
            }
        } else {
            WaterIntakeService.shared.fetchGlassCount(for: targetDate) {
                [weak cell, weak collectionView] count in
                let progress = Float(count) / 10.0
                DispatchQueue.main.async {
                    guard let cell = cell,
                        let collectionView = collectionView,
                        collectionView.indexPath(for: cell) == indexPath
                    else {
                        return
                    }
                    cell.waterProgress = progress
                }
            }
        }

        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
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

    func scrollViewDidEndDragging(
        _ scrollView: UIScrollView,
        willDecelerate decelerate: Bool
    ) {
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
            x: dateCollectionView.contentOffset.x + dateCollectionView.bounds
                .width / 2,
            y: dateCollectionView.bounds.height / 2
        )

        if let indexPath = dateCollectionView.indexPathForItem(at: centerPoint)
        {
            // Select the centered cell
            dateCollectionView.selectItem(
                at: indexPath,
                animated: false,
                scrollPosition: []
            )

            // Update the selected date
            updateMonthLabel(for: indexPath.row)
            updateWaterIntakeUI()
        }
    }

    // MARK: - Helper Methods

    private func getDateForIndex(_ index: Int) -> Date {
        let calendar = Calendar.current
        let today = Date()
        let daysOffset = index - 15

        return calendar.date(byAdding: .day, value: daysOffset, to: today)
            ?? today
    }
}
