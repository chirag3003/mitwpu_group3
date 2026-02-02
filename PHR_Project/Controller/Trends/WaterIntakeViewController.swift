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
    
    //insights
    @IBOutlet weak var insight1: UIView!
    @IBOutlet weak var insight2: UIView!
    
    // MARK: - Properties
    var dates: MealDataStore = MealDataStore.shared
    var hasScrolledToToday = false
    
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
        
        // View Styling
        insight1.addRoundedCorner(radius: 20)
        insight2.addRoundedCorner(radius: 20)
        
        
        // Initial Progress Setup
        progressView.configure(mode: .achievement, progress: 0.8, thickness: UIConstants.ProgressThickness.thick)
        
        setupWaterIntakeGestures()
        setupNotificationObservers()
        updateWaterIntakeUI()
        
        // Initialize header with today's month
        updateMonthLabel(for: 15)
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
        WaterIntakeService.shared.incrementGlass()
        animateGlassValue()
        self.provideHapticFeedback()
    }
    
    @objc func decrementGlassCount() {
        WaterIntakeService.shared.decrementGlass()
        animateGlassValue()
        self.provideHapticFeedback()
    }
    
    @objc func handleWaterIntakeUpdate() {
        updateWaterIntakeUI()
    }
    
    func updateWaterIntakeUI() {
        let count = WaterIntakeService.shared.getGlassCount()
        glassValue.text = "\(count)"
        
        // Calculate progress percentage (Goal = 10 glasses)
        let progress = Float(count) / 10.0
        progressView.configure(
            mode: .achievement,
            progress: min(progress, 1.0),
            thickness: UIConstants.ProgressThickness.thick
        )
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
        cell.configureCell(date: date)
        
        // Highlight today visually
        cell.isToday = (indexPath.row == 15)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.scrollToItem(
            at: indexPath,
            at: .centeredHorizontally,
            animated: true
        )
        
        updateMonthLabel(for: indexPath.row)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
}
