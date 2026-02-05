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

    // Receive data from previous screen (HeightScaleViewController)
    var profileDataArray: [String: Any] = [:]
    
    // Track the current unit
    private var isKgSelected: Bool = true
    
    // Store the weight in kg (always use kg as the base unit)
    private var weightInKg: Double = 70
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Print received data from previous screen
        print("Received data from Height VC:", profileDataArray)
        
        setupSegmentedControl()
        setupScaleView()
    }
    
    // MARK: - Setup
    private func setupSegmentedControl() {
        unitSegmentedControl.removeAllSegments()
        unitSegmentedControl.insertSegment(withTitle: "kg", at: 0, animated: false)
        unitSegmentedControl.insertSegment(withTitle: "lbs", at: 1, animated: false)
        unitSegmentedControl.selectedSegmentIndex = 0 // Default to kg
        
        unitSegmentedControl.addTarget(self, action: #selector(unitSegmentChanged(_:)), for: .valueChanged)
    }
    
    private func setupScaleView() {
        // Configure for weight in kg initially
        scaleRulerView.configure(
            min: 30,
            max: 200,
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
                self.weightInKg = value
                self.valueLabel.text = "\(Int(value))"
                //print("Selected weight: \(Int(value)) kg")
            } else {
                // Value is in lbs, convert to kg for storage
                self.weightInKg = value / 2.20462
                self.valueLabel.text = "\(Int(value))"
                //print("Selected weight: \(Int(value)) lbs (\(Int(self.weightInKg)) kg)")
            }
        }
        
        updateDisplay()
    }
    
    // MARK: - Actions
    @IBAction func unitSegmentChanged(_ sender: UISegmentedControl) {
        let previousUnit = isKgSelected
        isKgSelected = (sender.selectedSegmentIndex == 0)
        
        if previousUnit != isKgSelected {
            reconfigureScaleForUnit()
            
            let unit = isKgSelected ? "kg" : "lbs"
            //print("Unit changed to: \(unit)")
            printCurrentWeight()
        }
    }
    
    @IBAction func nextBtn(_ sender: Any) {
        saveDataToArray()
        printCurrentData()
    }
    
    
    // MARK: - Data Management
    private func saveDataToArray() {
        // Saving weight as an Integer in KG
        profileDataArray["weight"] = Int(weightInKg)
    }
    
    private func printCurrentData() {
        print("========== Profile Data ==========")
        print("First Name: \(profileDataArray["firstName"] ?? "")")
        print("Last Name: \(profileDataArray["lastName"] ?? "")")
        print("Gender: \(profileDataArray["sex"] ?? "")")
        print("DoB: \(profileDataArray["dob"] ?? "")")
        print("Age: \(profileDataArray["age"] ?? "")")
        print("Height: \(profileDataArray["height"] ?? 0) cm")
        print("Weight: \(profileDataArray["weight"] ?? 0) kg")
        print("==================================")
    }
    
    // MARK: - Private Methods
    private func reconfigureScaleForUnit() {
        if isKgSelected {
            let currentKg = weightInKg
            scaleRulerView.configure(
                min: 30,
                max: 200,
                initial: max(30, min(200, currentKg)),
                spacing: 5
            )
        } else {
            let currentLbs = weightInKg * 2.20462
            scaleRulerView.configure(
                min: 66,
                max: 440,
                initial: max(66, min(440, currentLbs)),
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
    
    private func printCurrentWeight() {
        if isKgSelected {
            print("Current weight: \(Int(weightInKg)) kg")
        } else {
            let lbs = weightInKg * 2.20462
            print("Current weight: \(Int(lbs)) lbs (\(Int(weightInKg)) kg)")
        }
    }
    
    // MARK: - Public Methods
    func getWeightInKg() -> Double { return weightInKg }
    func getWeightInLbs() -> Double { return weightInKg * 2.20462 }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Pass the updated array to the next screen (e.g., SummaryViewController)
        saveDataToArray()
        if let diabetesTypeVC = segue.destination as? DiabetesTypeViewController {
            diabetesTypeVC.profileDataArray = profileDataArray
        }
    }
}
