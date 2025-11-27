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
    
    func configureCell(date: Date){
        dayCell.text = date.day
        
        viewDateCell.addRoundedCorner(radius: 20)
        
        dateLabel.text = date.number
    }
    
}
