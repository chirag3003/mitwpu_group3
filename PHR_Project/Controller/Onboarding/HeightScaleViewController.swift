//
//  HeightScaleViewController.swift
//  PHR_Project
//
//  Created by Sushant Pulipati on 02/02/26.
//

import UIKit

class HeightScaleViewController: UIViewController {

    @IBOutlet weak var unitSegmentedControl: UISegmentedControl!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var scaleRulerView: ScaleRulerView!
    
    // Track the current unit
    private var isCmSelected: Bool = true
    
    // Store the height in cm (always use cm as the base unit)
    private var heightInCm: Double = 176
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSegmentedControl()
        setupScaleView()
    }
    
    // MARK: - Setup
    private func setupSegmentedControl() {
        // Configure segmented control
        unitSegmentedControl.removeAllSegments()
        unitSegmentedControl.insertSegment(withTitle: "cm", at: 0, animated: false)
        unitSegmentedControl.insertSegment(withTitle: "in", at: 1, animated: false)
        unitSegmentedControl.selectedSegmentIndex = 0
        
        
        unitSegmentedControl.addTarget(self, action: #selector(unitSegmentChanged(_:)), for: .valueChanged)
    }
    
    private func setupScaleView() {
        // Configure for height in cm initially
        scaleRulerView.configure(
            min: 140,
            max: 220,
            initial: 176,
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
            
            if self.isCmSelected {
                // Value is in cm
                self.heightInCm = value
                self.valueLabel.text = "\(Int(value))"
            } else {
                // Value is in inches, convert to cm for storage
                self.heightInCm = value * 2.54
                
                // Display as feet and inches
                let totalInches = value
                let feet = Int(totalInches / 12)
                let inches = Int(totalInches.truncatingRemainder(dividingBy: 12))
                self.valueLabel.text = "\(feet)'\(inches)\""
            }
        }
        
        updateDisplay()
    }
    
    // MARK: - Actions
    @IBAction func unitSegmentChanged(_ sender: UISegmentedControl) {
        let previousUnit = isCmSelected
        isCmSelected = (sender.selectedSegmentIndex == 0)
        
        if previousUnit != isCmSelected {
            reconfigureScaleForUnit()
        }
    }
    
    // MARK: - Private Methods
    private func reconfigureScaleForUnit() {
        if isCmSelected {
            // Switch to cm
            let currentCm = heightInCm
            
            scaleRulerView.configure(
                min: 80,
                max: 220,
                initial: max(140, min(220, currentCm)),
                spacing: 5
            )
            
        } else {
            let currentInches = heightInCm / 2.54
            
            scaleRulerView.configure(
                min: 11,
                max: 87,
                initial: max(55, min(87, currentInches)),
                spacing: 5
            )
        }
        
        updateDisplay()
    }
    
    private func updateDisplay() {
        if isCmSelected {
            valueLabel.text = "\(Int(heightInCm))"
        } else {
            let (feet, inches) = getHeightInFeetAndInches()
            valueLabel.text = "\(feet)'\(inches)\""
        }
    }
    
    // MARK: - Public Methods
    
    /// Get the current height in cm (regardless of display unit)
    func getHeightInCm() -> Double {
        return heightInCm
    }
    
    /// Get the current height in inches (regardless of display unit)
    func getHeightInInches() -> Double {
        return heightInCm / 2.54
    }
    
    /// Get the current height in feet and inches
    func getHeightInFeetAndInches() -> (feet: Int, inches: Int) {
        let totalInches = heightInCm / 2.54
        let feet = Int(totalInches / 12)
        let inches = Int(totalInches.truncatingRemainder(dividingBy: 12))
        return (feet, inches)
    }
}
