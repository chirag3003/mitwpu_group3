//
//  GlucoseViewController.swift
//  PHR_Project
//
//  Created by Sushant Pulipati on 09/12/25.
//

import UIKit
import SwiftUI
import Combine  

class GlucoseViewController: UIViewController {

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
    private let chartViewModel = ChartViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupChart()
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
        
        //custom stack spacing
        glucoseGraphStack.setCustomSpacing(-5, after: glucoseValueStack)

        chartViewModel.updateData(for: .week)
            
            // 2. Make sure the visual button matches the data (assuming "Week" is index 1)
            if let segment = chartSegmentControl {
                segment.selectedSegmentIndex = 1
            }
        // Do any additional setup after loading the view.
        
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
            // 2. Pass the ViewModel to the SwiftUI View
            let chartView = GlucoseChartView(viewModel: chartViewModel)
            
            let hostingController = UIHostingController(rootView: chartView)
            
            addChild(hostingController)
            hostingController.view.frame = chartContainerView.bounds
            hostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            hostingController.view.backgroundColor = UIColor.clear
            
            chartContainerView.addSubview(hostingController.view)
            hostingController.didMove(toParent: self)
        }
}
