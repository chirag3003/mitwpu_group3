//
//  PrescriptionTableViewCell.swift
//  PHR_Project
//
//  Created by SDC-USER on 27/11/25.
//

import UIKit

class PrescriptionTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = "PrescriptionCell"
    
    // MARK: - IBOutlets (Connect in Interface Builder)
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCell()
    }
    
    // MARK: - Setup
    private func setupCell() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none
        
        containerView.addRoundedCorner(radius: 15)
        iconImageView.addFullRoundedCorner()
    }
    
    // MARK: - Configure
    func configure(with prescription: PrescriptionModel) {
        titleLabel.text = prescription.lastUpdatedAt
    }
    
    // MARK: - Selection Feedback
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        UIView.animate(withDuration: 0.1) {
            self.containerView?.backgroundColor = highlighted ? .systemGray5 : .white
        }
    }
}
