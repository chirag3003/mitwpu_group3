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
    
    // Empty State View (created programmatically or via storyboard if exists, assuming programmatic for now)
    private let noDataLabel: UILabel = {
        let label = UILabel()
        label.text = "No glucose data logged yet.\nTap + to add a reading."
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        return label
    }()
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
        setupEmptyState()
        
        // Listen for updates
        NotificationCenter.default.addObserver(self, selector: #selector(updateDataFromService), name: NSNotification.Name("GlucoseReadingsUpdated"), object: nil)
        
        // Initial Fetch
        GlucoseService.shared.fetchReadings()
        updateDataFromService()
    }
    
    func setupEmptyState() {
        view.addSubview(noDataLabel)
        noDataLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            noDataLabel.centerXAnchor.constraint(equalTo: graphView.centerXAnchor),
            noDataLabel.centerYAnchor.constraint(equalTo: graphView.centerYAnchor)
        ])
        noDataLabel.isHidden = true
    }
    
    @objc func updateDataFromService() {
        applyFilter()
    }
    
    func applyFilter() {
        let readings = GlucoseService.shared.getReadings()
        let calendar = Calendar.current
        let now = Date()
        
        let filteredReadings: [GlucoseReading]
        
        let selectedIndex = chartSegmentControl?.selectedSegmentIndex ?? 1
        
        switch selectedIndex {
        case 0: // Day
            if let start = calendar.date(byAdding: .day, value: -1, to: now) {
                filteredReadings = readings.filter { $0.dateRecorded >= start }
            } else { filteredReadings = readings }
        case 1: // Week
            if let start = calendar.date(byAdding: .day, value: -7, to: now) {
                filteredReadings = readings.filter { $0.dateRecorded >= start }
            } else { filteredReadings = readings }
        case 2: // Month
            if let start = calendar.date(byAdding: .month, value: -1, to: now) {
                filteredReadings = readings.filter { $0.dateRecorded >= start }
            } else { filteredReadings = readings }
        case 3: // 6 Months
            if let start = calendar.date(byAdding: .month, value: -6, to: now) {
                filteredReadings = readings.filter { $0.dateRecorded >= start }
            } else { filteredReadings = readings }
        case 4: // Year
            if let start = calendar.date(byAdding: .year, value: -1, to: now) {
                filteredReadings = readings.filter { $0.dateRecorded >= start }
            } else { filteredReadings = readings }
        default:
            filteredReadings = readings
        }
        
        // Map to DataPoints
        let points = filteredReadings.map { GlucoseDataPoint(date: $0.dateRecorded, value: $0.value) }
        let sortedPoints = points.sorted { $0.date < $1.date }
        
        // Update Chart
        chartViewModel.dataPoints = sortedPoints
        
        // Handle Empty State
        if sortedPoints.isEmpty {
            noDataLabel.isHidden = false
            chartContainerView.isHidden = true // Hide chart to show label clearly
            // Reset Labels
            if let l = lastLoggedLabel { l.text = "--" }
            if let l = averageLabel { l.text = "--" }
            if let l = minLabel { l.text = "--" }
            if let l = maxLabel { l.text = "--" }
        } else {
            noDataLabel.isHidden = true
            chartContainerView.isHidden = false
            if let latest = sortedPoints.last {
                updateDashboardLabels(latestPoint: latest, allPoints: sortedPoints)
            }
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
        
    func updateDashboardLabels(latestPoint: GlucoseDataPoint, allPoints: [GlucoseDataPoint]) {
        // Update "Last Logged"
        if let label = lastLoggedLabel {
            label.text = "\(latestPoint.value)"
        }
        
        // Calculate and Update Stats
        let values = allPoints.map { $0.value }
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
        // Just re-apply the filter on existing data
        applyFilter()
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
