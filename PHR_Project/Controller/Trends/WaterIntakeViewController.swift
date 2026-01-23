//
//  WaterIntakeViewController.swift
//  PHR_Project
//
//  Created by Sushant Pulipati on 14/01/26.
//

import UIKit

class WaterIntakeViewController: UIViewController {

    @IBOutlet weak var progressView: CircularProgressView!
    @IBOutlet weak var monthName: UILabel!
    @IBOutlet weak var dateCollectionView: UICollectionView!
    
    @IBOutlet weak var glassValue: UILabel!
    @IBOutlet weak var increment: UIImageView!
    @IBOutlet weak var decrement: UIImageView!
    
    @IBOutlet weak var insight1: UIView!
    @IBOutlet weak var insight2: UIView!
    @IBOutlet weak var insight3: UIView!
    
    var dates: MealDataStore = MealDataStore.shared
    var hasScrolledToToday = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dateCollectionView.dataSource = self
        dateCollectionView.delegate = self
        dateCollectionView.setCollectionViewLayout(
            createDateLayout(),
            animated: true
        )
        
        insight1.addRoundedCorner(radius: 20)
        insight2.addRoundedCorner(radius: 20)
        insight3.addRoundedCorner(radius: 20)
        
        progressView.configure(mode: .achievement, progress: 0.8, thickness: UIConstants.ProgressThickness.thick)
        
        setupWaterIntakeGestures()
        
       
        setupNotificationObservers()
        
        // Update UI with current water intake
        updateWaterIntakeUI()
        
        updateMonthLabel(for: 15)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Refresh water intake UI when view appears
        updateWaterIntakeUI()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
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
            // Absolute height 100 ensures enough space for Circle + Text
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0/7.0),
                heightDimension: .absolute(100)
            )

            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize,
                subitems: [item]
            )
            
            // 3. Section
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .groupPagingCentered

            return section
        }
    }
    
    // Update month label based on selected date index
    private func updateMonthLabel(for index: Int) {
        //let selectedDate = dates.getDays()[index]
        
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
}


private extension WaterIntakeViewController {
    
    func setupWaterIntakeGestures() {
        increment.isUserInteractionEnabled = true
        decrement.isUserInteractionEnabled = true
        
        let incrementTap = UITapGestureRecognizer(target: self, action: #selector(incrementGlassCount))
        increment.addGestureRecognizer(incrementTap)
        
        let decrementTap = UITapGestureRecognizer(target: self, action: #selector(decrementGlassCount))
        decrement.addGestureRecognizer(decrementTap)
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
        
        // Update progress view based on glass count (assuming 8 glasses is the goal)
        let progress = Float(count) / 10.0
        progressView.configure(
            mode: progress >= 1.0 ? .achievement : .achievement,
            progress: min(progress, 1.0),
            thickness: UIConstants.ProgressThickness.thick
        )
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


extension WaterIntakeViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
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
        let cell = collectionView.dequeueReusableCell(
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
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        collectionView.scrollToItem(
            at: indexPath,
            at: .centeredHorizontally,
            animated: true
        )
        
        let selectedDay = dates.getDays()[indexPath.row]
        
        // Update month label when date is selected
        updateMonthLabel(for: indexPath.row)
        
        // TODO: Update water intake data for selected date
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
}
