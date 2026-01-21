//
//  DatesCollectionViewCell.swift
//  PHR_Project
//
//  Created by Sushant Pulipati on 27/11/25.
//

import UIKit

class DatesCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var viewDateCell: UIView!
    @IBOutlet weak var dayCell: UILabel!
    
    var isToday: Bool = false {
        didSet {
            updatedAppearance()
        }
    }
    
    override var isSelected: Bool {
        didSet {oldValue != isSelected {
                    
        }
            updatedAppearance()
        }
    }
    
    private func updatedAppearance() {
        // Define the dynamic color for unselected state
        let unselectedColor = UIColor { (traitCollection: UITraitCollection) -> UIColor in
            if traitCollection.userInterfaceStyle == .dark {
                // Your requested hex #6FAAE6 for Dark Mode
                return UIColor(red: 111/255, green: 170/255, blue: 220/255, alpha: 1.0)
            } else {
                // Your existing Light Mode color
                return UIColor(red: 190/255, green: 226/255, blue: 255/255, alpha: 1.0)
            }
        }

        if isSelected {
            viewDateCell.backgroundColor = UIColor(red: 101/255, green: 187/255, blue: 255/255, alpha: 1)
            viewDateCell.layer.borderWidth = 0 // Clear border if selected
            dateLabel.textColor = .label
            dayCell.textColor = .label
            
        } else if isToday {
            viewDateCell.backgroundColor = unselectedColor
            viewDateCell.layer.borderWidth = 1
            viewDateCell.layer.borderColor = UIColor.label.cgColor // Use .label so it's white in dark mode
            dateLabel.textColor = .label
            dayCell.textColor = .label
            
        } else {
            viewDateCell.backgroundColor = unselectedColor
            viewDateCell.layer.borderWidth = 0
            dateLabel.textColor = .secondaryLabel
            dayCell.textColor = .secondaryLabel
        }
    }
    
    func configureCell(date: CalendarDay){
        dayCell.text = date.day
        
        viewDateCell.addRoundedCorner(radius: 18)
        
        dateLabel.text = date.number
    }
    
    override func prepareForReuse() {
            super.prepareForReuse()
            isToday = false
            viewDateCell.layer.borderWidth = 0
        }
    
}

