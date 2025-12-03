//
//  MealViewController.swift
//  PHR_Project
//
//  Created by Sushant Pulipati on 25/11/25.
//

import UIKit

class MealViewController: UIViewController {

    @IBOutlet weak var dateCollectionView: UICollectionView!
    
    
    var dates: MealDataStore = MealDataStore.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateCollectionView.dataSource = self
        dateCollectionView.setCollectionViewLayout(createLayout(), animated: true)

    }
    
    private func createLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout {
            (sectionIndex, env) -> NSCollectionLayoutSection? in
            
            
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0/7.0),
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
                count: 7 // This divides the screen width by 7 automatically
            )
            // 3. Section
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .groupPaging
            
            return section
        }
    }
}

extension MealViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dates.getDays().count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "date_cell", for: indexPath) as! DatesCollectionViewCell
        
        let date = dates.getDays()[indexPath.row]
        
        cell.configureCell(date: date)
        
        return cell
    }
    
    
}
