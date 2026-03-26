import Combine
import SwiftUI
import UIKit

class StepsViewController: UIViewController, FamilyMemberDataScreen {

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
    
    var familyMember: FamilyMember? {
        didSet {
            viewModel.familyMember = familyMember
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupStyling()
        setupChart()
        setupBindings()
        
        if familyMember != nil {
            self.title = "\(familyMember!.name)'s Steps"
            viewModel.requestAuthorization() // requestAuthorization now handles family member logic
        } else {
            self.title = "Steps"
            viewModel.requestAuthorization()
        }
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
            
        // Bind Insights
        viewModel.$insights
            .receive(on: RunLoop.main)
            .sink { [weak self] insights in
                self?.updatePatternViews(with: insights)
            }
            .store(in: &cancellables)
            
        viewModel.$activitySummary
            .receive(on: RunLoop.main)
            .sink { [weak self] summary in
                self?.updateHighlightView(with: summary)
            }
            .store(in: &cancellables)
    }

    private func updatePatternViews(with insights: [ActivityInsight]) {
        let patternViews = [firstPatternView, secondPatternView, thirdPatternView]
        
        // Hide all initially
        patternViews.forEach { $0?.isHidden = true }
        
        for (index, insight) in insights.enumerated() {
            guard index < patternViews.count else { break }
            let view = patternViews[index]
            view?.isHidden = false
            
            // Update labels inside the view
            if let labels = view?.subviews.compactMap({ $0 as? UILabel }) {
                // Find title and description labels by their expected traits
                // Typically: title is bold or higher in hierarchy
                if let titleLabel = labels.first(where: { $0.font.fontName.contains("Bold") }) ?? labels.first {
                    titleLabel.text = insight.title
                    
                    if let descLabel = labels.first(where: { $0 != titleLabel }) {
                        descLabel.text = insight.description
                    }
                }
            }
        }
    }

    private func updateHighlightView(with summary: String) {
        if let labels = highlightView?.subviews.compactMap({ $0 as? UILabel }),
           let summaryLabel = labels.first {
            summaryLabel.text = summary
        }
    }

    @IBAction func segmentChanged(_ sender: UISegmentedControl) {

        guard let range = StepsTimeRange(rawValue: sender.selectedSegmentIndex)
        else { return }
        viewModel.updateData(for: range)
    }

    func setupChart() {
        let chartView = StepsChartView(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: chartView)

        addChild(hostingController)
        hostingController.view.frame = chartContainerView.bounds
        hostingController.view.autoresizingMask = [
            .flexibleWidth, .flexibleHeight,
        ]
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
