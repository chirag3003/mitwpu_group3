//
//  SymptomTableViewCell.swift
//  PHR_Project
//
//  Created by SDC_USER on 28/11/25.
//

import UIKit

class SymptomTableViewCell: UITableViewCell {

    @IBOutlet weak var intensityLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var notesLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var cardView: UIView!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureSymptomCell(with symptom: Symptom) {
            
        cardView.addRoundedCorner(radius: 20)
        cardView.applyLiquidGlassEffect()
            // 1. Basic Text
            nameLabel.text = symptom.symptomName
            intensityLabel.text = "Intensity: \(symptom.intensity)"
            notesLabel.text = symptom.notes
            
            // 2. Format the Date (Using your custom Date struct)
            // Accesses the .day ("Fri") and .number ("28") from your data
            let dayStr = symptom.dateRecorded.day
            let numStr = symptom.dateRecorded.number
            dateLabel.text = "Logged \(dayStr) \(numStr)"
            
            // 3. Format the Time (DateComponents -> String)
            if let hour = symptom.time?.hour, let minute = symptom.time?.minute {
                
                // Logic to convert 24h (14:00) to 12h (2:00 pm)
                let amPm = hour >= 12 ? "pm" : "am"
                let hour12 = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour)
                
                // %02d ensures that 5 minutes becomes "05"
                let minuteString = String(format: "%02d", minute)
                
                timeLabel.text = "\(hour12).\(minuteString) \(amPm)"
            } else {
                // Fallback if time is nil
                timeLabel.text = "--.--"
            }
        }
    
   

}
