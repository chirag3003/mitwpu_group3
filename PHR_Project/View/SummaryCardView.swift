//
//  SummaryCardView.swift
//  PHR_Project
//
//  Created by SDC_USER on 24/11/25.
//

import UIKit

class SummaryCardView: UIView {

    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        layer.cornerRadius = 30
        layer.masksToBounds = true
    }
}
