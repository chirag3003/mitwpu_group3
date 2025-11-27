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

    }

}

//extension MealViewController: UICollectionViewDataSource {
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        <#code#>
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        <#code#>
//    }
//    
//    
//}
