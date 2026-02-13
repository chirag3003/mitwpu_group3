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
    private var progressView: UIView?
    var cellMode: DateCellMode = .normal {
        didSet {
            updateAppearance()
        }
    }
    
    var waterProgress: Float = 0.0 {
        didSet {
            if cellMode == .waterIntake {
                updateProgressView()
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
        let lightBlueColor = UIColor { (traitCollection: UITraitCollection) -> UIColor in
            if traitCollection.userInterfaceStyle == .dark {
                return UIColor(red: 111/255, green: 170/255, blue: 220/255, alpha: 1.0)
            } else {
                return UIColor(red: 190/255, green: 226/255, blue: 255/255, alpha: 1.0)
            }
        }


        
        viewDateCell.backgroundColor = lightBlueColor

        if isSelected {
            // Selected state: Light blue + thick black border
            viewDateCell.layer.borderWidth = 1.5
            viewDateCell.layer.borderColor = UIColor.label.cgColor
            dateLabel.textColor = .label
            dayCell.textColor = .label
        }
        else if isToday {
            // Today (but not selected): Light blue + thin border
            viewDateCell.layer.borderWidth = 1
            viewDateCell.layer.borderColor = UIColor.label.cgColor
            dateLabel.textColor = .label
            dayCell.textColor = .label
            
        } else {
            // Normal state: Light blue, no border
            viewDateCell.layer.borderWidth = 0
            dateLabel.textColor = .secondaryLabel
            dayCell.textColor = .secondaryLabel
        }

        
        // Update progress layer if in water mode
        if cellMode == .waterIntake {
            updateProgressView()
        }
    }
    
    func configureCell(date: CalendarDay, mode: DateCellMode = .normal) {
        self.cellMode = mode
        dayCell.text = date.day
        dateLabel.text = date.number
        viewDateCell.addRoundedCorner(radius: 18)
        if mode == .normal {
            progressView?.removeFromSuperview()
            progressView = nil
        } else if mode == .waterIntake {
            // Setup progress view for water mode if not already present
            if progressView == nil {
                setupProgressView()
            }
        }
        // Remove progress view if switching
    }
    private func setupProgressView() {
        // Remove existing if any
        progressView?.removeFromSuperview()
        
        // Create a simple UIView for progress
        let pView = UIView()
        pView.backgroundColor = UIColor(red: 101/255, green: 181/255, blue: 255/255, alpha: 1.0)
        pView.layer.cornerRadius = 18
        pView.clipsToBounds = true
        
        // Add to viewDateCell at the bottom (index 0)
        viewDateCell.insertSubview(pView, at: 0)
        progressView = pView
        
        // Set initial frame
        updateProgressView()
    }
    private func updateProgressView() {
        guard cellMode == .waterIntake else {
            progressView?.removeFromSuperview()
            progressView = nil
            return
        }
        
        // Ensure we have a progress view
        if progressView == nil {
            setupProgressView()
        }
        
        guard let pView = progressView else { return }
        
        // Calculate progress percentage (clamped between 0 and 1)
        let progress = CGFloat(min(max(waterProgress, 0.0), 1.0))
        
        print("📈 Updating progress view: progress=\(progress), bounds=\(viewDateCell.bounds)")
        
        // Calculate height based on progress (fill from bottom)
        let totalHeight = viewDateCell.bounds.height
        let progressHeight = totalHeight * progress
        // Position the progress view at the bottom
        let yPosition = totalHeight - progressHeight
        
        pView.frame = CGRect(
            x: 0,
            y: yPosition,
            width: viewDateCell.bounds.width,
            height: progressHeight
        )
        // Hide if no progress
        pView.isHidden = (progress <= 0)
        
        // Ensure labels are on top
        viewDateCell.bringSubviewToFront(dateLabel)
        viewDateCell.bringSubviewToFront(dayCell)
    }
    
    
    // MARK: - Water Progress Visualization
    
    
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Update progress view frame when cell resizes
        if cellMode == .waterIntake {
            updateProgressView()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // Reset all properties to avoid visual glitches
        isToday = false
        isSelected = false  // ← NEW: Critical fix!
        waterProgress = 0.0
        cellMode = .normal
        viewDateCell.layer.borderWidth = 0
        
        // Remove and nil out progress view
        progressView?.removeFromSuperview()
        progressView = nil
    }
}
