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
        
        if let segment = chartSegmentControl {
            segment.selectedSegmentIndex = 1
        }
        
        setupChart()
        setupStyling()
        
        // Listen for updates
        NotificationCenter.default.addObserver(self, selector: #selector(updateDataFromService), name: NSNotification.Name("GlucoseReadingsUpdated"), object: nil)
        
        // Initial Fetch
        GlucoseService.shared.fetchReadings()
        updateDataFromService()
    }
    
    @objc func updateDataFromService() {
        let readings = GlucoseService.shared.getReadings()
        
        // Map to GlucoseDataPoint for the existing chart view model
        let points = readings.map { reading in
            return GlucoseDataPoint(date: reading.dateRecorded, value: reading.value)
        }
        
        // Sort
        let sortedPoints = points.sorted { $0.date < $1.date }
        
        // Update Chart
        chartViewModel.dataPoints = sortedPoints
        
        // Update Stats labels
        if let latest = sortedPoints.last {
            updateDashboardLabels(latestPoint: latest)
        }
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
        
        // 3. Protocol Implementation (Legacy/Unused but kept for satisfying protocol if needed, or removed if protocol is optional)
    func didAddGlucoseData(point: GlucoseDataPoint) {
        // No-op: Data is now handled via Service + Notification
        // But we refresh just in case
        updateDataFromService()
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
