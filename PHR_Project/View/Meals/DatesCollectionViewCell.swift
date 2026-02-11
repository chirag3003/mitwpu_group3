//
//  DatesCollectionViewCell.swift
//  PHR_Project
//
//  Created by Sushant Pulipati on 27/11/25.
//

import UIKit

enum DateCellMode {
    case normal      // For meal tracking page
    case waterIntake // For water intake page with progress
}

class DatesCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var viewDateCell: UIView!
    @IBOutlet weak var dayCell: UILabel!
    
    // Progress layer for water intake visualization
    private var progressLayer: CALayer?
    
    var cellMode: DateCellMode = .normal {
        didSet {
            updateAppearance()
        }
    }
    
    var waterProgress: Float = 0.0 {
        didSet {
            if cellMode == .waterIntake {
                updateProgressLayer()
            }
        }
    }
    
    var isToday: Bool = false {
        didSet {
            updateAppearance()
        }
    }
    
    override var isSelected: Bool {
        didSet {
            updateAppearance()
        }
    }
    
    private func updateAppearance() {
        // Define the dynamic color for unselected state
        let unselectedColor = UIColor { (traitCollection: UITraitCollection) -> UIColor in
            if traitCollection.userInterfaceStyle == .dark {
                return UIColor(red: 111/255, green: 170/255, blue: 220/255, alpha: 1.0)
            } else {
                return UIColor(red: 190/255, green: 226/255, blue: 255/255, alpha: 1.0)
            }
        }

        if isSelected {
            viewDateCell.backgroundColor = UIColor(red: 101/255, green: 187/255, blue: 255/255, alpha: 1)
            viewDateCell.layer.borderWidth = 0
            dateLabel.textColor = .label
            dayCell.textColor = .label
            
        } else if isToday {
            viewDateCell.backgroundColor = unselectedColor
            viewDateCell.layer.borderWidth = 1
            viewDateCell.layer.borderColor = UIColor.label.cgColor
            dateLabel.textColor = .label
            dayCell.textColor = .label
            
        } else {
            viewDateCell.backgroundColor = unselectedColor
            viewDateCell.layer.borderWidth = 0
            dateLabel.textColor = .secondaryLabel
            dayCell.textColor = .secondaryLabel
        }
        
        // Update progress layer if in water mode
        if cellMode == .waterIntake {
            updateProgressLayer()
        }
    }
    
    func configureCell(date: CalendarDay, mode: DateCellMode = .normal) {
        self.cellMode = mode
        dayCell.text = date.day
        dateLabel.text = date.number
        viewDateCell.addRoundedCorner(radius: 18)
        
        // Remove progress layer if switching to normal mode
        if mode == .normal {
            progressLayer?.removeFromSuperlayer()
            progressLayer = nil
        }
    }
    
    // MARK: - Water Progress Visualization
    
    private func updateProgressLayer() {
        guard cellMode == .waterIntake else {
            progressLayer?.removeFromSuperlayer()
            progressLayer = nil
            return
        }
        
        // Remove existing layer
        progressLayer?.removeFromSuperlayer()
        
        // Don't show progress layer if progress is 0
        guard waterProgress > 0 else { return }
        
        // Create gradient layer for progress
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = viewDateCell.bounds
        gradientLayer.cornerRadius = 18
        
        // Dark blue for progress, light blue for remaining
        let darkBlue = UIColor(red: 45/255, green: 120/255, blue: 180/255, alpha: 1.0).cgColor
        let lightBlue = UIColor { (traitCollection: UITraitCollection) -> UIColor in
            if traitCollection.userInterfaceStyle == .dark {
                return UIColor(red: 111/255, green: 170/255, blue: 220/255, alpha: 1.0)
            } else {
                return UIColor(red: 190/255, green: 226/255, blue: 255/255, alpha: 1.0)
            }
        }.cgColor
        
        // Calculate progress percentage (clamped between 0 and 1)
        let progress = CGFloat(min(max(waterProgress, 0.0), 1.0))
        
        // Vertical gradient: bottom to top fill
        gradientLayer.colors = [darkBlue, darkBlue, lightBlue, lightBlue]
        gradientLayer.locations = [0, NSNumber(value: progress), NSNumber(value: progress), 1]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 1) // Bottom
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0)   // Top
        
        // Insert below content
        viewDateCell.layer.insertSublayer(gradientLayer, at: 0)
        progressLayer = gradientLayer
        
        // Bring text labels to front
        viewDateCell.bringSubviewToFront(dateLabel)
        viewDateCell.bringSubviewToFront(dayCell)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Update progress layer frame when cell resizes
        if let layer = progressLayer {
            layer.frame = viewDateCell.bounds
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        isToday = false
        waterProgress = 0.0
        cellMode = .normal
        viewDateCell.layer.borderWidth = 0
        progressLayer?.removeFromSuperlayer()
        progressLayer = nil
    }
}
