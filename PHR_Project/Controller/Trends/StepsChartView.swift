import SwiftUI
import Charts

struct StepsChartView: View {
    @ObservedObject var viewModel: StepsViewModel
    @State private var selectedDate: Date?
    
    var body: some View {
        if #available(iOS 16.0, *) {
            GeometryReader { geometry in
                ScrollViewReader { scrollProxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        ZStack(alignment: .leading) {
                            
                            // 👻 LAYER 1: The "Ghost" Scroll Targets (Using INDICES)
                            // We use simple Int indices (0, 1, 2...) which are bulletproof for scrolling
                            HStack(spacing: 0) {
                                ForEach(Array(viewModel.dataPoints.enumerated()), id: \.offset) { index, point in
                                    Color.clear
                                        .frame(width: getSingleBarWidth(availableWidth: geometry.size.width))
                                        .id(index) // <--- ID is now a simple Integer (0, 1, 2...)
                                }
                            }
                            .frame(height: 1) // Minimal height, just needs to exist
                            
                            // 📊 LAYER 2: The Actual Chart
                            Chart {
                                ForEach(viewModel.dataPoints) { point in
                                    
                                    let barUnit: Calendar.Component = {
                                        switch viewModel.currentRange {
                                        case .day: return .hour
                                        case .week, .month: return .day
                                        case .sixMonth: return .weekOfYear
                                        case .year: return .month
                                        }
                                    }()
                                    
                                    BarMark(
                                        x: .value("Time", point.date, unit: barUnit),
                                        y: .value("Steps", point.count)
                                    )
                                    .foregroundStyle(Color.blue)
                                    .cornerRadius(4)
                                    
                                    if let selectedDate, selectedDate == point.date {
                                        RuleMark(x: .value("Selected", selectedDate))
                                            .foregroundStyle(Color.gray.opacity(0.5))
                                            .annotation(position: .top) {
                                                Text("\(point.count)")
                                                    .font(.caption.bold())
                                                    .padding(4)
                                                    .background(.white)
                                                    .cornerRadius(4)
                                                    .shadow(radius: 2)
                                            }
                                    }
                                }
                            }
                            .frame(width: calculateTotalWidth(availableWidth: geometry.size.width))
                            .chartXAxis {
                                AxisMarks(values: .automatic) { _ in
                                    AxisTick()
                                    AxisValueLabel(format: xAxisFormat(), centered: true)
                                }
                            }
                        }
                        .padding(.top)
                    }
                    // ⚡️ SCROLL TRIGGERS
                    .onAppear {
                        scrollToEnd(proxy: scrollProxy)
                    }
                    .onChange(of: viewModel.currentRange) {
                        scrollToEnd(proxy: scrollProxy)
                    }
                    // Trigger scroll whenever the data updates (e.g. data loads from HealthKit)
                    .onChange(of: viewModel.dataPoints.count) {
                        scrollToEnd(proxy: scrollProxy)
                    }
                }
            }
        } else {
            Text("iOS 16+ Required")
        }
    }
    
    // ⚡️ HELPER: Scroll to the last available data point (Current Time)
    func scrollToEnd(proxy: ScrollViewProxy) {
        // Slight delay to ensure the View is rendered before we try to scroll
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation {
                let count = viewModel.dataPoints.count
                if count > 0 {
                    // Scroll to the last index (count - 1)
                    // anchor: .trailing aligns the "Now" bar to the right side of the screen
                    // anchor: .center aligns it to the middle
                    proxy.scrollTo(count - 1, anchor: .trailing)
                }
            }
        }
    }
    
    func xAxisFormat() -> Date.FormatStyle {
        switch viewModel.currentRange {
        case .day: return .dateTime.hour()
        case .week, .month: return .dateTime.day().month()
        case .sixMonth: return .dateTime.month().day()
        case .year: return .dateTime.month(.abbreviated)
        }
    }
    
    func getSingleBarWidth(availableWidth: CGFloat) -> CGFloat {
        switch viewModel.currentRange {
        case .day: return 40
        case .week: return availableWidth / 7
        case .month: return 20
        case .sixMonth: return 30
        case .year: return availableWidth / 12
        }
    }
    
    func calculateTotalWidth(availableWidth: CGFloat) -> CGFloat {
        let count = CGFloat(viewModel.dataPoints.count)
        if count == 0 { return availableWidth }
        
        switch viewModel.currentRange {
        case .day: return count * 40
        case .week: return availableWidth
        case .month: return count * 20
        case .sixMonth: return count * 30
        case .year: return availableWidth
        }
    }
}
