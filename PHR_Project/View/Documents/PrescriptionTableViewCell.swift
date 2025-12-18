//
//  ReportsTableViewCell.swift
//  PHR_Project
//
//  Created by SDC-USER on 27/11/25.
//

import UIKit

class PrescriptionTableViewCell: UITableViewCell {

    @IBOutlet weak var fileImage: UIImageView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var fileSize: UILabel!
    @IBOutlet weak var lastUpdatedAt: UILabel!
    @IBOutlet weak var reportName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(
        with report: PrescriptionModel) {
            mainView.addRoundedCorner(radius: 15)
            fileImage.addRoundedCorner(radius: 15)
            
        reportName.text = report.title
        fileSize.text = "\(report.fileSize)"
        lastUpdatedAt.text = "\(report.lastUpdatedAt)"
    }

}
