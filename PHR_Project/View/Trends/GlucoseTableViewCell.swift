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

    func configure(date: String, subtitle: String, glucose: String) {
        glucoseLabel.text = glucose
        subtitleLabel.text = subtitle
        dateLabel.text = date
    }

}
