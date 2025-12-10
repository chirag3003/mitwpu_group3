//
//  SymptomTableViewCell.swift
//  PHR_Project
//
//  Created by SDC_USER on 28/11/25.
//

import UIKit

class SymptomTableViewCell: UITableViewCell {

    @IBOutlet weak var cardView: UIView!

    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var subtitleLabel: UILabel!

    @IBOutlet weak var dateLabel: UILabel!

    @IBOutlet weak var timeLabel: UILabel!

    @IBOutlet weak var severityView: UIView!

    @IBOutlet weak var severityLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupStyle()
    }

    func setupStyle() {
        // Card Shadow & Radius
        cardView.layer.cornerRadius = 20
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.08
        cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cardView.layer.shadowRadius = 6

        // Badge Styling
        severityView.layer.cornerRadius = 10
        severityView.clipsToBounds = true
    }

    // MARK: - Configuration
    func configure(with symptom: Symptom) {

        // 1. Text Data
        titleLabel.text = symptom.symptomName
        if symptom.notes == nil || symptom.notes == "" {
            subtitleLabel.text = "No notes"
        } else {
            subtitleLabel.text = symptom.notes
        }
        severityLabel.text = symptom.intensity

        // 2. Date Formatting (New Logic for "21st Oct 2025")
        dateLabel.text = formatDateWithOrdinal(date: symptom.dateRecorded)

        // 3. Time Formatting
        if let dateFromComponents = Calendar.current.date(from: symptom.time) {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            timeLabel.text = "\(formatter.string(from: dateFromComponents))"
        } else {
            timeLabel.text = "--:--"
        }

        // 4. Badge Color Logic
        switch symptom.intensity {
        case "High": severityView.backgroundColor = .systemRed
        case "Medium": severityView.backgroundColor = .systemOrange
        case "Low": severityView.backgroundColor = .systemGreen
        default: severityView.backgroundColor = .systemGray
        }
    }

    // Helper Function to create "21st", "2nd", "3rd", "4th"
    private func formatDateWithOrdinal(date: Foundation.Date) -> String {
        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)

        // Determine suffix (st, nd, rd, th)
        let numberSuffix: String
        switch day {
        case 1, 21, 31: numberSuffix = "st"
        case 2, 22: numberSuffix = "nd"
        case 3, 23: numberSuffix = "rd"
        default: numberSuffix = "th"
        }

        // Format the rest (Month Year)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM yyyy"  // "Oct 2025"

        let monthYear = dateFormatter.string(from: date)

        return "\(day)\(numberSuffix) \(monthYear)"
    }

}
