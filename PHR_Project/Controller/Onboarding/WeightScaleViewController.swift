//
//  WeightScaleViewController.swift
//  PHR_Project
//
//  Created by Sushant Pulipati on 02/02/26.
//

import UIKit

class WeightScaleViewController: UIViewController {

    @IBOutlet weak var unitSegmentedControl: UISegmentedControl!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var scaleRulerView: ScaleRulerView!

        // Track the current unit
        private var isKgSelected: Bool = true
        
        // Store the weight in kg (always use kg as the base unit)
        private var weightInKg: Double = 70
        
        override func viewDidLoad() {
            super.viewDidLoad()
            setupSegmentedControl()
            setupScaleView()
        }
        
        // MARK: - Setup
        private func setupSegmentedControl() {
            // Configure segmented control
            unitSegmentedControl.removeAllSegments()
            unitSegmentedControl.insertSegment(withTitle: "kg", at: 0, animated: false)
            unitSegmentedControl.insertSegment(withTitle: "lbs", at: 1, animated: false)
            unitSegmentedControl.selectedSegmentIndex = 0 // Default to kg
            
            // Add target for value change
            unitSegmentedControl.addTarget(self, action: #selector(unitSegmentChanged(_:)), for: .valueChanged)
        }
        
        private func setupScaleView() {
            // Configure for weight in kg initially
            scaleRulerView.configure(
                min: 30,
                max: 150,
                initial: 70,
                spacing: 5
            )
            
            // Customize colors
            scaleRulerView.indicatorColor = .white
            scaleRulerView.majorTickColor = UIColor.lightGray.withAlphaComponent(0.7)
            scaleRulerView.mediumTickColor = UIColor.lightGray.withAlphaComponent(0.5)
            scaleRulerView.minorTickColor = UIColor.lightGray.withAlphaComponent(0.3)
            
            // Handle value changes
            scaleRulerView.valueChangedHandler = { [weak self] value in
                guard let self = self else { return }
                
                if self.isKgSelected {
                    // Value is in kg
                    self.weightInKg = value
                    self.valueLabel.text = "\(Int(value))"
                } else {
                    // Value is in lbs, convert to kg for storage
                    self.weightInKg = value / 2.20462
                    self.valueLabel.text = "\(Int(value))"
                }
            }
            
            // Set initial display
            updateDisplay()
        }
        
        // MARK: - Actions
        @IBAction func unitSegmentChanged(_ sender: UISegmentedControl) {
            let previousUnit = isKgSelected
            isKgSelected = (sender.selectedSegmentIndex == 0)
            
            if previousUnit != isKgSelected {
                // Unit changed, reconfigure the scale
                reconfigureScaleForUnit()
            }
        }
        
        // MARK: - Private Methods
        private func reconfigureScaleForUnit() {
            if isKgSelected {
                // Switch to kg
                let currentKg = weightInKg
                
                scaleRulerView.configure(
                    min: 30,
                    max: 150,
                    initial: currentKg,
                    spacing: 5
                )
                
            } else {
                // Switch to lbs
                let currentLbs = weightInKg * 2.20462
                
                scaleRulerView.configure(
                    min: 66,
                    max: 330,
                    initial: currentLbs,
                    spacing: 5
                )
            }
            
            updateDisplay()
        }
        
        private func updateDisplay() {
            if isKgSelected {
                valueLabel.text = "\(Int(weightInKg))"
            } else {
                let lbs = weightInKg * 2.20462
                valueLabel.text = "\(Int(lbs))"
            }
        }
        
        // MARK: - Public Methods
        
        /// Get the current weight in kg (regardless of display unit)
        func getWeightInKg() -> Double {
            return weightInKg
        }
        
        /// Get the current weight in lbs (regardless of display unit)
        func getWeightInLbs() -> Double {
            return weightInKg * 2.20462
        }
    }
