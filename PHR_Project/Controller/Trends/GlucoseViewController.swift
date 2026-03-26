import Combine
import SwiftUI
import UIKit

class GlucoseViewController: UIViewController, AddGlucoseDelegate,
    FamilyMemberDataScreen, SharedWriteAccessReceiving
{

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

    //Pattern2
    @IBOutlet weak var pattern2Description: UILabel!
    @IBOutlet weak var pattern2Title: UILabel!
    @IBOutlet weak var pattern2View: UIView!

    //Pattern
    @IBOutlet weak var pattern1Description: UILabel!
    @IBOutlet weak var pattern1Title: UILabel!
    @IBOutlet weak var pattern1View: UIView!

    //Highlights
    @IBOutlet weak var highlight1Description: UILabel!
    @IBOutlet weak var highlight1Title: UILabel!
    @IBOutlet weak var hightlight1View: UIView!

    @IBOutlet weak var maxView: UIView!
    @IBOutlet weak var minView: UIView!
    @IBOutlet weak var avgView: UIView!
    @IBOutlet weak var chartContainerView: UIView!
    @IBOutlet weak var graphView: UIView!

    @IBOutlet weak var lastLoggedLabel: UILabel!

    @IBOutlet weak var minLabel: UILabel!
    @IBOutlet weak var averageLabel: UILabel!

    @IBOutlet weak var maxLabel: UILabel!

    var familyMember: FamilyMember?
    private var sharedReadings: [GlucoseReading] = []
    var canEditSharedData = false

    private let chartViewModel = ChartViewModel()

    // Insights data from API
    private var glucoseInsights: GlucoseInsightsResponse?
    override func viewDidLoad() {
        super.viewDidLoad()

        if let segment = chartSegmentControl {
            segment.selectedSegmentIndex = 1
        }

        setupChart()
        setupStyling()
        setupEmptyState()
        setupInsightCards()

        // Listen for updates
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateDataFromService),
            name: NSNotification.Name(NotificationNames.glucoseUpdated),
            object: nil
        )

        // Initial Fetch
        if let member = familyMember {
            loadSharedReadings(for: member)
        } else {
            GlucoseService.shared.fetchReadings()
            updateDataFromService()
        }

        // Fetch AI insights from API
        fetchGlucoseInsights()

        //Setting up family member details
        if familyMember != nil {
            self.title = "\(familyMember!.name)'s Glucose"
            navigationItem.rightBarButtonItem?.isEnabled = canEditSharedData
        } else {
            self.title = "Glucose"
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Insights API

    private func setupInsightCards() {
        // Show first cards with loading placeholder, hide second pattern
        hightlight1View.isHidden = false
        highlight1Title.text = "Loading Insights..."
        highlight1Description.text = "Analyzing your glucose data"

        pattern1View.isHidden = false
        pattern1Title.text = "Loading Patterns..."
        pattern1Description.text = "Detecting glucose patterns"

        pattern2View.isHidden = true
    }

    private func fetchGlucoseInsights() {
        if let member = familyMember {
            InsightsService.shared.fetchSharedGlucoseInsights(
                userId: member.userId
            ) {
                [weak self] response in
                guard let self = self, let insights = response else { return }
                self.glucoseInsights = insights
                self.updateInsightsUI(with: insights)
            }
            return
        }

        InsightsService.shared.fetchGlucoseInsights { [weak self] response in
            guard let self = self, let insights = response else { return }

            self.glucoseInsights = insights
            self.updateInsightsUI(with: insights)
        }
    }

    private func updateInsightsUI(with response: GlucoseInsightsResponse) {
        // Update highlight card with first insight
        if response.insights.count >= 1 {
            let insight = response.insights[0]
            highlight1Title.text = insight.title
            highlight1Description.text = insight.description
            hightlight1View.isHidden = false
        }

        // Update pattern cards
        if response.patterns.count >= 1 {
            let pattern = response.patterns[0]
            pattern1Title.text = pattern.pattern
            pattern1Description.text =
                "\(pattern.frequency)\n\(pattern.recommendation)"
            pattern1View.isHidden = false
        }

        if response.patterns.count >= 2 {
            let pattern = response.patterns[1]
            pattern2Title.text = pattern.pattern
            pattern2Description.text =
                "\(pattern.frequency)\n\(pattern.recommendation)"
            pattern2View.isHidden = false
        }
    }

    func setupEmptyState() {
        view.addSubview(noDataLabel)
        noDataLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            noDataLabel.centerXAnchor.constraint(
                equalTo: graphView.centerXAnchor
            ),
            noDataLabel.centerYAnchor.constraint(
                equalTo: graphView.centerYAnchor
            ),
        ])
        noDataLabel.isHidden = true
    }

    @objc func updateDataFromService() {
        if familyMember != nil {
            applySharedFilter()
        } else {
            applyFilter()
        }
    }

    func applyFilter() {
        let readings = GlucoseService.shared.getReadings()
        let calendar = Calendar.current
        let now = Date()

        var filteredReadings: [GlucoseReading] = []

        let selectedIndex = chartSegmentControl?.selectedSegmentIndex ?? 1

        switch selectedIndex {
        case 0:  // Day - Since Midnight
            let start = calendar.startOfDay(for: now)
            filteredReadings = readings.filter { $0.dateRecorded >= start }
            chartViewModel.currentRange = .day

        case 1:  // Week - Last 7 Days
            if let start = calendar.date(byAdding: .day, value: -7, to: now) {
                filteredReadings = readings.filter { $0.dateRecorded >= start }
            } else {
                filteredReadings = readings
            }
            chartViewModel.currentRange = .week

        case 2:  // Month - Last 30 Days
            if let start = calendar.date(byAdding: .month, value: -1, to: now) {
                filteredReadings = readings.filter { $0.dateRecorded >= start }
            } else {
                filteredReadings = readings
            }
            chartViewModel.currentRange = .month

        case 3:  // 6 Months
            if let start = calendar.date(byAdding: .month, value: -6, to: now) {
                filteredReadings = readings.filter { $0.dateRecorded >= start }
            } else {
                filteredReadings = readings
            }
            chartViewModel.currentRange = .sixMonth

        case 4:  // Year
            if let start = calendar.date(byAdding: .year, value: -1, to: now) {
                filteredReadings = readings.filter { $0.dateRecorded >= start }
            } else {
                filteredReadings = readings
            }
            chartViewModel.currentRange = .year

        default:
            filteredReadings = readings
            chartViewModel.currentRange = .week
        }

        // Map to DataPoints
        // Map to DataPoints and Deduplicate (Keep latest value for duplicate timestamps)
        var uniquePointsDict: [Date: Int] = [:]
        for reading in filteredReadings {
            // CRITICAL FIX: Use combinedDate (Date + Time) instead of just dateRecorded (Date only)
            // This ensures readings at different times on the same day are distinct.
            uniquePointsDict[reading.combinedDate] = reading.value
        }

        let uniquePoints = uniquePointsDict.map {
            GlucoseDataPoint(date: $0.key, value: $0.value)
        }
        let sortedPoints = uniquePoints.sorted { $0.date < $1.date }

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            // Update Chart
            self.chartViewModel.dataPoints = sortedPoints

            // Handle Empty State
            if sortedPoints.isEmpty {
                self.noDataLabel.isHidden = false
                self.chartContainerView.isHidden = true

                // Reset Labels
                self.lastLoggedLabel?.text = "--"
                self.averageLabel?.text = "--"
                self.minLabel?.text = "--"
                self.maxLabel?.text = "--"
            } else {
                self.noDataLabel.isHidden = true
                self.chartContainerView.isHidden = false
                if let latest = sortedPoints.last {
                    self.updateDashboardLabels(
                        latestPoint: latest,
                        allPoints: sortedPoints
                    )
                }
            }
        }
    }

    func applySharedFilter() {
        let readings = sharedReadings
        let calendar = Calendar.current
        let now = Date()

        var filteredReadings: [GlucoseReading] = []

        let selectedIndex = chartSegmentControl?.selectedSegmentIndex ?? 1

        switch selectedIndex {
        case 0:  // Day - Since Midnight
            let start = calendar.startOfDay(for: now)
            filteredReadings = readings.filter { $0.dateRecorded >= start }
            chartViewModel.currentRange = .day

        case 1:  // Week - Last 7 Days
            if let start = calendar.date(byAdding: .day, value: -7, to: now) {
                filteredReadings = readings.filter { $0.dateRecorded >= start }
            } else {
                filteredReadings = readings
            }
            chartViewModel.currentRange = .week

        case 2:  // Month - Last 30 Days
            if let start = calendar.date(byAdding: .month, value: -1, to: now) {
                filteredReadings = readings.filter { $0.dateRecorded >= start }
            } else {
                filteredReadings = readings
            }
            chartViewModel.currentRange = .month

        case 3:  // 6 Months
            if let start = calendar.date(byAdding: .month, value: -6, to: now) {
                filteredReadings = readings.filter { $0.dateRecorded >= start }
            } else {
                filteredReadings = readings
            }
            chartViewModel.currentRange = .sixMonth

        case 4:  // Year
            if let start = calendar.date(byAdding: .year, value: -1, to: now) {
                filteredReadings = readings.filter { $0.dateRecorded >= start }
            } else {
                filteredReadings = readings
            }
            chartViewModel.currentRange = .year

        default:
            filteredReadings = readings
            chartViewModel.currentRange = .week
        }

        var uniquePointsDict: [Date: Int] = [:]
        for reading in filteredReadings {
            uniquePointsDict[reading.combinedDate] = reading.value
        }

        let uniquePoints = uniquePointsDict.map {
            GlucoseDataPoint(date: $0.key, value: $0.value)
        }
        let sortedPoints = uniquePoints.sorted { $0.date < $1.date }

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            self.chartViewModel.dataPoints = sortedPoints

            if sortedPoints.isEmpty {
                self.noDataLabel.isHidden = false
                self.chartContainerView.isHidden = true

                self.lastLoggedLabel?.text = "--"
                self.averageLabel?.text = "--"
                self.minLabel?.text = "--"
                self.maxLabel?.text = "--"
            } else {
                self.noDataLabel.isHidden = true
                self.chartContainerView.isHidden = false
                if let latest = sortedPoints.last {
                    self.updateDashboardLabels(
                        latestPoint: latest,
                        allPoints: sortedPoints
                    )
                }
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Check if the destination is the Add Controller (or a Nav Controller holding it)
        if let nav = segue.destination as? UINavigationController,
            let addVC = nav.topViewController as? AddGlucoseModalViewController
        {
            addVC.delegate = self
            addVC.view.isUserInteractionEnabled =
                familyMember == nil || canEditSharedData
            addVC.familyMember = familyMember
            addVC.canEditSharedData = canEditSharedData
        } else if let addVC = segue.destination
            as? AddGlucoseModalViewController
        {
            addVC.delegate = self
            addVC.view.isUserInteractionEnabled =
                familyMember == nil || canEditSharedData
            addVC.familyMember = familyMember
            addVC.canEditSharedData = canEditSharedData
        } else if var destination = segue.destination as? FamilyMemberDataScreen
        {
            destination.familyMember = familyMember
        }
    }

    // 3. Protocol Implementation (Legacy/Unused but kept for satisfying protocol if needed, or removed if protocol is optional)
    func didAddGlucoseData(point: GlucoseDataPoint) {
        // No-op: Data is now handled via Service + Notification
        // But we refresh just in case
        updateDataFromService()
    }

    func updateDashboardLabels(
        latestPoint: GlucoseDataPoint,
        allPoints: [GlucoseDataPoint]
    ) {
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
        if familyMember != nil {
            applySharedFilter()
        } else {
            applyFilter()
        }
    }

    func setupChart() {
        let chartView = GlucoseChartView(viewModel: chartViewModel)
        let hostingController = UIHostingController(rootView: chartView)

        addChild(hostingController)
        hostingController.view.frame = chartContainerView.bounds
        hostingController.view.autoresizingMask = [
            .flexibleWidth, .flexibleHeight,
        ]
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
        hightlight1View.addRoundedCorner(radius: 20)
        pattern1View.addRoundedCorner(radius: 20)
        pattern2View.addRoundedCorner(radius: 20)
        glucoseGraphStack.setCustomSpacing(-5, after: glucoseValueStack)
    }

    private func loadSharedReadings(for member: FamilyMember) {
        SharedDataService.shared.fetchGlucoseReadings(for: member.userId) {
            [weak self] result in
            switch result {
            case .success(let readings):
                self?.sharedReadings = readings
                self?.applySharedFilter()
            case .failure(let error):
                print("Error fetching shared glucose: \(error)")
            }
        }
    }
}
