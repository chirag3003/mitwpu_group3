//
//  GlucoseViewController.swift
//  PHR_Project
//
//  Created by Sushant Pulipati on 09/12/25.
//

import UIKit
import SwiftUI
import Combine  

class GlucoseViewController: UIViewController, AddGlucoseDelegate {

    @IBOutlet weak var chartSegmentControl: UISegmentedControl!
    @IBOutlet weak var glucoseValueStack: UIStackView!
    @IBOutlet weak var glucoseGraphStack: UIStackView!
    @IBOutlet weak var postDinnerSecondView: UIView!
    @IBOutlet weak var exerciseBenefitsView: UIView!
    @IBOutlet weak var postDinnerView: UIView!
    @IBOutlet weak var iapView: UIView!
    @IBOutlet weak var maxView: UIView!
    @IBOutlet weak var minView: UIView!
    @IBOutlet weak var avgView: UIView!
    @IBOutlet weak var chartContainerView: UIView!
    @IBOutlet weak var graphView: UIView!
    
    @IBOutlet weak var lastLoggedLabel: UILabel!
    
    @IBOutlet weak var minLabel: UILabel!
    @IBOutlet weak var averageLabel: UILabel!
    
    @IBOutlet weak var maxLabel: UILabel!
    
    private let chartViewModel = ChartViewModel()
    override func viewDidLoad() {
            super.viewDidLoad()
            
            // Load data BEFORE setting up the chart
            chartViewModel.updateData(for: .week)
            
            if let segment = chartSegmentControl {
                segment.selectedSegmentIndex = 1
            }
            
            setupChart()
            setupStyling()
        }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            // Check if the destination is the Add Controller (or a Nav Controller holding it)
            if let nav = segue.destination as? UINavigationController,
               let addVC = nav.topViewController as? AddGlucoseModalViewController {
                addVC.delegate = self
            }
            else if let addVC = segue.destination as? AddGlucoseModalViewController {
                addVC.delegate = self
            }
        }
        
        // 3. The Protocol Implementation: This runs when "Done" is clicked
    func didAddGlucoseData(point: GlucoseDataPoint) {
        // 1. Create a copy of the current data
        var updatedData = chartViewModel.dataPoints
        
        // 2. Remove any "Dummy" data that is too close to the new point (Optional but recommended)
        // This prevents having two points at almost the same time (e.g., 4:00 PM and 4:05 PM)
        updatedData.removeAll { existingPoint in
            let timeDifference = abs(existingPoint.date.timeIntervalSince(point.date))
            return timeDifference < 300 // Remove points within 5 minutes of the new one
        }
        
        // 3. Append the new point
        updatedData.append(point)
        
        // 4. Sort strictly by date
        updatedData.sort { $0.date < $1.date }
        
        // 5. Assign back to the ViewModel in one go
        // This triggers ONLY ONE redraw, preventing the "glitch/distortion"
        chartViewModel.dataPoints = updatedData
        
        // 6. Update Labels
        updateDashboardLabels(latestPoint: point)
    }
        
        func updateDashboardLabels(latestPoint: GlucoseDataPoint) {
            // Update "Last Logged"
            if let label = lastLoggedLabel {
                label.text = "\(latestPoint.value)"
            }
            
            // Calculate and Update Stats
            let values = chartViewModel.dataPoints.map { $0.value }
            if !values.isEmpty {
                let avg = values.reduce(0, +) / values.count
                let min = values.min() ?? 0
                let max = values.max() ?? 0
                
                if let l = averageLabel { l.text = "\(avg)" }
                if let l = minLabel { l.text = "\(min)" }
                if let l = maxLabel { l.text = "\(max)" }
            }
        }
    
    @IBAction func timeSegmentChanged(_ sender: UISegmentedControl) {
            switch sender.selectedSegmentIndex {
            case 0: // Day (D)
                chartViewModel.updateData(for: .day)
            case 1: // Week (W)
                chartViewModel.updateData(for: .week)
            case 2: // Month (M)
                chartViewModel.updateData(for: .month)
            case 3: // 6 Months (6M)
                chartViewModel.updateData(for: .sixMonth)
            case 4: // Year (Y)
                chartViewModel.updateData(for: .year)
            default:
                break
            }
        }

    func setupChart() {
            let chartView = GlucoseChartView(viewModel: chartViewModel)
            let hostingController = UIHostingController(rootView: chartView)
            
            addChild(hostingController)
            hostingController.view.frame = chartContainerView.bounds
            hostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            hostingController.view.backgroundColor = UIColor.clear
            
            chartContainerView.addSubview(hostingController.view)
            hostingController.didMove(toParent: self)
        }
        
        func setupStyling() {
            graphView.addRoundedCorner()
            chartContainerView.addRoundedCorner()
            avgView.addRoundedCorner()
            avgView.addDropShadow()
            minView.addRoundedCorner()
            minView.addDropShadow()
            maxView.addRoundedCorner()
            maxView.addDropShadow()
            iapView.addRoundedCorner(radius: 10)
            postDinnerView.addRoundedCorner(radius: 10)
            exerciseBenefitsView.addRoundedCorner(radius: 10)
            postDinnerSecondView.addRoundedCorner(radius: 10)
            glucoseGraphStack.setCustomSpacing(-5, after: glucoseValueStack)
        }
}
