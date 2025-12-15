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
        didSet {
            updatedAppearance()
        }
    }
    
    private func updatedAppearance() {
        if isSelected {
            viewDateCell.backgroundColor = UIColor(
                red: 101/255,
                green: 187/255,
                blue: 255/255,
                alpha: 1
            )
            dateLabel.textColor = .label
            dayCell.textColor = .label
            
        }else if isToday{
//            viewDateCell.backgroundColor = UIColor(
//                red: 101/255,
//                green: 187/255,
//                blue: 255/255,
//                alpha: 1
//            )
            dayCell.textColor = .label
            viewDateCell.layer.borderWidth = 1
            viewDateCell.layer.borderColor = UIColor.black.cgColor
            
        } else {
            viewDateCell.backgroundColor = UIColor(
                red: 190/255,
                green: 226/255,
                blue: 255/255,
                alpha: 1
                )
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

