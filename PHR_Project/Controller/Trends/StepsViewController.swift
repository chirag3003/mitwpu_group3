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
            setupBindings()
            viewModel.requestAuthorization()
        }
            
        func setupBindings() {
            viewModel.$mainStatValue
                .receive(on: RunLoop.main)
                .sink { [weak self] value in
                    self?.totalStepsLabel.text = value
                }
                .store(in: &cancellables)
                
            viewModel.$mainStatTitle
                .receive(on: RunLoop.main)
                .sink { [weak self] title in
                    self?.totalLabel.text = title
                }
                .store(in: &cancellables)
        }
            
        @IBAction func segmentChanged(_ sender: UISegmentedControl) {
           
            guard let range = StepsTimeRange(rawValue: sender.selectedSegmentIndex) else { return }
            viewModel.updateData(for: range)
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
            // Keep your existing styling code here...
            stepsContainerView?.addRoundedCorner()
            highlightView?.addRoundedCorner(radius: 20)
            firstPatternView?.addRoundedCorner(radius: 20)
            secondPatternView?.addRoundedCorner(radius: 20)
            thirdPatternView?.addRoundedCorner(radius: 20)
            chartContainerView?.addRoundedCorner()
            stepViewStack?.setCustomSpacing(-5, after: stepValueStack)
        }
    }
