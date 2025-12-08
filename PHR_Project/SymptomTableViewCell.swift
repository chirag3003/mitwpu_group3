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
            subtitleLabel.text = symptom.notes ?? "No notes"
            severityLabel.text = symptom.intensity
            
            // 2. Date Formatting (Combining your custom struct)
            // Output: "Mon, 16th"
            dateLabel.text = "\(symptom.dateRecorded.day) \(symptom.dateRecorded.number)"
            
            // 3. Time Formatting (DateComponents -> String)
            if let dateFromComponents = Calendar.current.date(from: symptom.time) {
                let formatter = DateFormatter()
                formatter.timeStyle = .short // e.g., "9:30 AM"
                timeLabel.text = "\(formatter.string(from: dateFromComponents))"
            } else {
                timeLabel.text = "--:--"
            }
            
            // 4. Badge Color Logic
            switch symptom.intensity {
            case "High":
                severityView.backgroundColor = .systemRed
            case "Medium":
                severityView.backgroundColor = .systemOrange
            case "Low":
                severityView.backgroundColor = .systemGreen
            default:
                severityView.backgroundColor = .systemGray
            }
        }
   

}
