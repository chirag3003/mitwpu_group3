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
        dateCollectionView.setCollectionViewLayout(
            createDateLayout(),
            animated: true
        )
        
        calorieProgressView.configure(progress: 0.49, thickness: 25.0)
        
        
        carbsProgress.configure(progress: 0.81, thickness: 12.0)
        carbsProgress.addRoundedCorner()
        carbsProgress.addDropShadow()
        
        proteinProgress.configure(progress: 0.66, thickness: 12.0)
        proteinProgress.addRoundedCorner()
        proteinProgress.addDropShadow()
        
        fiberProgress.configure(progress: 0.71, thickness: 12.0)
        fiberProgress.addRoundedCorner()
        fiberProgress.addDropShadow()
        
        insightOne.addRoundedCorner(radius: 10)
        insightTwo.addRoundedCorner(radius: 10)
        
        
        
        setupMealCollectionView()

    }

    private func createDateLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout {
            (sectionIndex, env) -> NSCollectionLayoutSection? in

            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0 / 7.0),
                    heightDimension: .fractionalHeight(1.0)
                )
            )
            item.contentInsets = NSDirectionalEdgeInsets(
                top: 8,
                leading: 8,
                bottom: 8,
                trailing: 8
            )

            // 2. Group
            // Absolute height 150 ensures enough space for Circle + Text
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(100)
            )

            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize,
                subitem: item,
                count: 7  // This divides the screen width by 7 automatically
            )
            // 3. Section
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .groupPaging

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
            config.headerTopPadding = 16
            config.showsSeparators = true
            config.backgroundColor = .clear

            let layout = UICollectionViewCompositionalLayout { sectionIndex, env in
                
                let section = NSCollectionLayoutSection.list(
                    using: config,
                    layoutEnvironment: env
                )

                section.contentInsets = NSDirectionalEdgeInsets(
                    top: 10,
                    leading: 0,
                    bottom: 10,
                    trailing: 0
                )

                let background = NSCollectionLayoutDecorationItem.background(
                    elementKind: "section-background"
                )
                
                background.contentInsets = NSDirectionalEdgeInsets(
                    top: 4,
                    leading: 0,
                    bottom: 4,
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

extension MealViewController: UICollectionViewDataSource,
    UICollectionViewDelegate
{
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        if collectionView == dateCollectionView {
            return dates.getDays().count
        }
        return meals[section].count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {

        if collectionView == dateCollectionView {
            let cell =
                collectionView.dequeueReusableCell(
                    withReuseIdentifier: "date_cell",
                    for: indexPath
                ) as! DatesCollectionViewCell

            let date = dates.getDays()[indexPath.row]

            cell.configureCell(date: date)

            return cell
        }

        let cell =
            collectionView.dequeueReusableCell(
                withReuseIdentifier: "MealCell",
                for: indexPath
            ) as! MealItemCollectionViewCell
        let meal = meals[indexPath.section][indexPath.row]
        return cell
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
                withReuseIdentifier: "SectionHeader",
                for: indexPath
            ) as! MealSectionHeaderView
        
        header.sectionLabel.text = sectionTitles[indexPath.section]
        return header
    }

}


