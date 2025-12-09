//
//  MealItemCollectionViewCell.swift
//  PHR_Project
//
//  Created by SDC-USER on 03/12/25.
//

import UIKit

class MealItemCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var mealImage: UIImageView!
    static let identifier: String = "MealCell"

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        mealImage.addRoundedCorner(radius: 10)
        self.backgroundColor = .clear 
        self.contentView.backgroundColor = .clear
    }
    }
