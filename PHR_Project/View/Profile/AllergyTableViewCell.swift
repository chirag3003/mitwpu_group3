//
//  AllergyTableViewCell.swift
//  PHR_Project
//
//  Created by SDC_USER on 27/11/25.
//

import UIKit

class AllergyTableViewCell: UITableViewCell {

    @IBOutlet weak var allergyColor: UIView!

    @IBOutlet weak var allergyLabel: UILabel!

    @IBOutlet weak var allergyDescLabel: UILabel!

    @IBOutlet weak var mainView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureCell(with allergy: Allergy) {
        mainView.addRoundedSides()
        allergyLabel.text = allergy.name
        allergyDescLabel.text = allergy.notes
        switch allergy.severity {
        case "High":
            allergyColor.backgroundColor = .red
        case "Medium":
            allergyColor.backgroundColor = .orange
        case "Low":
            allergyColor.backgroundColor = .yellow
        default:
            allergyColor.backgroundColor = .yellow
        }
    }

}
