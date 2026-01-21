//
//  StepsViewController.swift
//  PHR_Project
//
//  Created by SDC_USER on 21/01/26.
//

import UIKit
import Combine
import SwiftUI

class StepsViewController: UIViewController {

    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var stepValueStack: UIStackView!
    @IBOutlet weak var stepViewStack: UIStackView!
    @IBOutlet weak var totalStepsLabel: UILabel!
    @IBOutlet weak var stepsSegmentControl: UISegmentedControl!
    @IBOutlet weak var chartContainerView: UIView!
    @IBOutlet weak var thirdPatternView: UIView!
    @IBOutlet weak var secondPatternView: UIView!
    @IBOutlet weak var firstPatternView: UIView!
    @IBOutlet weak var highlightView: UIView!
    @IBOutlet weak var stepsContainerView: UIView!
    
    private let viewModel = StepsViewModel()
        private var cancellables = Set<AnyCancellable>()
        
        override func viewDidLoad() {
            super.viewDidLoad()
            setupStyling()
            setupChart()
            setupBindings() // 👈 Connect listeners
            
            // 3. Ask for Apple Health Permissions
            viewModel.requestAuthorization()
        }
        
    // In setupBindings():
        func setupBindings() {
            // Listen to the specific 'todaySteps' variable now
            viewModel.$todaySteps
                .receive(on: RunLoop.main)
                .sink { [weak self] steps in
                    self?.totalStepsLabel.text = "\(steps)"
                }
                .store(in: &cancellables)
        }
        
        @IBAction func segmentChanged(_ sender: UISegmentedControl) {
            switch sender.selectedSegmentIndex {
            case 0: viewModel.updateData(for: .day)
            case 1: viewModel.updateData(for: .week)
            case 2: viewModel.updateData(for: .month)
            case 3: viewModel.updateData(for: .sixMonth)
            case 4: viewModel.updateData(for: .year)
            default: break
            }
        }
        
        func setupChart() {
            let chartView = StepsChartView(viewModel: viewModel)
            let hostingController = UIHostingController(rootView: chartView)
            
            addChild(hostingController)
            hostingController.view.frame = chartContainerView.bounds
            hostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            hostingController.view.backgroundColor = .clear
            
            chartContainerView.addSubview(hostingController.view)
            hostingController.didMove(toParent: self)
        }
        
        func setupStyling() {
            stepsContainerView.addRoundedCorner()
            highlightView.addRoundedCorner(radius: 10)
            firstPatternView.addRoundedCorner(radius: 10)
            secondPatternView.addRoundedCorner(radius: 10)
            thirdPatternView.addRoundedCorner(radius: 10)
            chartContainerView.addRoundedCorner()
            stepViewStack.setCustomSpacing(-5, after: stepValueStack)
        }
    
    

    

}
