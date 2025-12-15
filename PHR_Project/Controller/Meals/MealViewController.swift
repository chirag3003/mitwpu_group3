//
//  MealViewController.swift
//  PHR_Project
//
//  Created by Sushant Pulipati on 25/11/25.
//

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


    @IBOutlet weak var insightOne: UIView!
    
    @IBOutlet weak var insightTwo: UIView!
    @IBOutlet weak var fiberProgress: SemicircularProgressView!
    @IBOutlet weak var proteinProgress: SemicircularProgressView!
    @IBOutlet weak var carbsProgress: SemicircularProgressView!
    @IBOutlet weak var calorieProgressView: CircularProgressView!
    @IBOutlet weak var mealCollectionView: MealItemCollectionView!
    @IBOutlet weak var dateCollectionView: UICollectionView!

    var dates: MealDataStore = MealDataStore.shared
    
    var hasScrolledToToday = false

    // Data Model
    struct Meal {
        let name: String
        let detail: String
        let time: String
        let image: String  // In real app, this might be UIImage or URL
    }

    // Data: Section 0 (Breakfast), Section 1 (Lunch), Section 2 (Dinner - Empty)
    let meals = [
        [
            Meal(
                name: "Coffee",
                detail: "1 cup",
                time: "9:00 am",
                image: "coffee"
            ),
            Meal(
                name: "Kellogs Granola",
                detail: "1 bowl",
                time: "9:20 am",
                image: "granola"
            ),
        ],

        [
            Meal(
                name: "Dal Rice",
                detail: "1 plate",
                time: "2:00 pm",
                image: "dal"
            )
        ],

        [
            Meal(
                name: "Dal Rice",
                detail: "1 plate",
                time: "2:00 pm",
                image: "dal"
            )
        ],  // Empty array for Dinner
    ]

    let sectionTitles = ["Breakfast", "Lunch", "Dinner"]

    override func viewDidLoad() {
        super.viewDidLoad()

        dateCollectionView.dataSource = self
        dateCollectionView.delegate = self
        dateCollectionView.setCollectionViewLayout(
            createDateLayout(),
            animated: true
        )
        
        calorieProgressView.configure(progress: 0.49, thickness: UIConstants.ProgressThickness.thick)
        
        carbsProgress.configure(progress: 0.81, thickness: UIConstants.ProgressThickness.thin)
        carbsProgress.addRoundedCorner()
        carbsProgress.addDropShadow()
        
        proteinProgress.configure(progress: 0.66, thickness: UIConstants.ProgressThickness.thin)
        proteinProgress.addRoundedCorner()
        proteinProgress.addDropShadow()
        
        fiberProgress.configure(progress: 0.71, thickness: UIConstants.ProgressThickness.thin)
        fiberProgress.addRoundedCorner()
        fiberProgress.addDropShadow()
        
        insightOne.addRoundedCorner(radius: UIConstants.CornerRadius.small)
        insightTwo.addRoundedCorner(radius: UIConstants.CornerRadius.small)
        
        
        
        setupMealCollectionView()

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

            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(UIConstants.CollectionLayout.oneSeventhWidth),
                    heightDimension: .fractionalHeight(UIConstants.CollectionLayout.fullWidth)
                )
            )
            
            item.contentInsets = NSDirectionalEdgeInsets(
                top: UIConstants.Spacing.small,
                leading: UIConstants.Spacing.small,
                bottom: UIConstants.Spacing.small,
                trailing: UIConstants.Spacing.small
            )

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(UIConstants.CollectionLayout.fullWidth),
                heightDimension: .absolute(UIConstants.CollectionLayout.dateItemHeight)
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

    private func setupMealCollectionView() {
        let mealNib = UINib(nibName: "MealItemCollectionViewCell", bundle: nil)
        mealCollectionView.register(
            mealNib,
            forCellWithReuseIdentifier: "MealCell"
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
        return meals[section].count
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

        let cell =
            collectionView.dequeueReusableCell(
                withReuseIdentifier: CellIdentifiers.mealCell,
                for: indexPath
            ) as! MealItemCollectionViewCell
        let meal = meals[indexPath.section][indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == dateCollectionView {
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
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
