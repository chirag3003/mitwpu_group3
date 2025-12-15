//
//  MealDetailTableViewCell.swift
//  PHR_Project
//
//  Created by Sushant Pulipati on 27/11/25.
//

import UIKit

class MealDetailTableViewCell: UITableViewCell {

    @IBOutlet weak var dataValue: UILabel!
    @IBOutlet weak var dataLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    
    }

}
