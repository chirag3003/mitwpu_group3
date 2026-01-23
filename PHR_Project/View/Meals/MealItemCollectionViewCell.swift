//
//  MealItemCollectionViewCell.swift
//  PHR_Project
//
//  Created by SDC-USER on 03/12/25.
//

import UIKit

class MealItemCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var mealName: UILabel!
    @IBOutlet weak var mealQty: UILabel!
    @IBOutlet weak var mealTime: UILabel!
    @IBOutlet weak var mealImage: UIImageView!

    static let identifier: String = "MealCell"

    override func awakeFromNib() {
        super.awakeFromNib()
        mealImage.addRoundedCorner(radius: UIConstants.CornerRadius.small)
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
    }

    func setup(with meal: Meal) {
        mealName.text = meal.name
        mealQty.text = meal.detail ?? ""
        mealTime.text = meal.time
        if let imagePath = meal.image, !imagePath.isEmpty,
            imagePath.hasPrefix("http")
        {
            mealImage.setImageFromURL(url: imagePath)
        }
    }

}
