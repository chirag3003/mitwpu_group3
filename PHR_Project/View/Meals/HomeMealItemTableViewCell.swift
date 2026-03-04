//
//  HomeMealItemTableViewCell.swift
//  PHR_Project
//
//  Created by Sushant Pulipati on 17/02/26.
//

import UIKit

class HomeMealItemTableViewCell: UITableViewCell {

    @IBOutlet weak var mealName: UILabel!
    @IBOutlet weak var carbs: UILabel!
    @IBOutlet weak var protein: UILabel!
    @IBOutlet weak var fiber: UILabel!
    @IBOutlet weak var mealImage: UIImageView!
    @IBOutlet weak var calories: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
