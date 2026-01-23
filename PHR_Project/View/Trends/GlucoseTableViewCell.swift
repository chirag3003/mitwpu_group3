//
//  GlucoseTableViewCell.swift
//  PHR_Project
//
//  Created by SDC-USER on 22/01/26.
//

import UIKit

class GlucoseTableViewCell: UITableViewCell {
    
    @IBOutlet weak var glucoseLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(date: String, subtitle: String, glucose: String){
        glucoseLabel.text = glucose
        subtitleLabel.text = subtitle
        dateLabel.text = date
    }

}
