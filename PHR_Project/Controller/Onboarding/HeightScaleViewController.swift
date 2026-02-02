//
//  HeightScaleViewController.swift
//  PHR_Project
//
//  Created by Sushant Pulipati on 02/02/26.
//

import UIKit

class HeightScaleViewController: UIViewController {

    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var scaleRulerView: ScaleRulerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScaleView()
    }
    
    // MARK: - Setup
    private func setupScaleView() {
        // Configure for height
        scaleRulerView.configure(
            min: 140,
            max: 220,
            initial: 176,
            spacing: 10
        )
        
        // Optional: Customize colors
        scaleRulerView.indicatorColor = .white
        scaleRulerView.majorTickColor = UIColor.lightGray.withAlphaComponent(0.7)
        
        // Handle value changes
        scaleRulerView.valueChangedHandler = { [weak self] value in
            self?.valueLabel.text = "\(Int(value))"
        }
        
        // Set initial value
        valueLabel.text = "176"
    }
}
