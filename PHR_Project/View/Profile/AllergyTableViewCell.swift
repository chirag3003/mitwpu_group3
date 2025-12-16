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
    @IBOutlet weak var mainView: UIView! //Main card view holding the cell
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func configureCell(with allergy: Allergy) {
        //Configure UI
//        contentView.applyLiquidGlassEffect()
        mainView.addRoundedSides()
        
        //Configuring Data
        allergyLabel.text = allergy.name
        allergyDescLabel.text = allergy.notes
        
        switch allergy.severity {
        case "High":
            allergyColor.backgroundColor = .red
        case "Moderate":
            allergyColor.backgroundColor = .orange
        case "Low":
            allergyColor.backgroundColor = .yellow
        default:
            allergyColor.backgroundColor = .yellow
        }
    }

}
