//
//  ReportsTableViewCell.swift
//  PHR_Project
//
//  Created by SDC-USER on 27/11/25.
//

import UIKit

class ReportsTableViewCell: UITableViewCell {

    @IBOutlet weak var fileImage: UIImageView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var fileSize: UILabel!
    @IBOutlet weak var lastUpdatedAt: UILabel!
    @IBOutlet weak var reportName: UILabel!

    func configure(
        with report: ReportModel) {
            mainView.addRoundedCorner(radius: 15)
            fileImage.addRoundedCorner(radius: 15)

        reportName.text = report.title
        fileSize.text = ""
        lastUpdatedAt.text = "\(report.lastUpdatedAt)"
    }

}
