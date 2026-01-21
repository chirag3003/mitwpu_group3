import SwiftUI
import Charts

struct StepsChartView: View {
    @ObservedObject var viewModel: StepsViewModel
    @State private var selectedDate: Date?
    @State private var selectedValue: Int?
    
    var body: some View {
        if #available(iOS 16.0, *) {
            GeometryReader { geometry in
                ScrollViewReader { scrollProxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        Chart {
                            ForEach(viewModel.dataPoints) { point in
                                let xUnit: Calendar.Component = (viewModel.currentRange == .day) ? .hour : .day
                                
                                // BAR GRAPH
                                BarMark(
                                    x: .value("Time", point.date, unit: xUnit),
                                    y: .value("Steps", point.count)
                                )
                                .foregroundStyle(Color.blue) // Dark bars like your design
                                .cornerRadius(4)
                                
                                // Selection Highlight (RuleMark)
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
                        // Dynamic Width Calculation
                        .frame(width: max(geometry.size.width, calculateWidth(availableWidth: geometry.size.width)))
                        .id("ChartEnd")
                        
                        // X-Axis Formatting
                        .chartXAxis {
                            AxisMarks(values: .automatic) { _ in
                                AxisTick()
                                AxisValueLabel(format: xAxisFormat(), centered: true)
                            }
                        }
                        .padding(.top)
                    }
                    .onAppear { scrollProxy.scrollTo("ChartEnd", anchor: .trailing) }
                    .onChange(of: viewModel.currentRange) { _, _ in
                        scrollProxy.scrollTo("ChartEnd", anchor: .trailing)
                    }
                }
            }
        } else {
            Text("iOS 16+ Required")
        }
    }
    
    // Formatting Helper
    func xAxisFormat() -> Date.FormatStyle {
        switch viewModel.currentRange {
        case .day: return .dateTime.hour()
        case .week, .month: return .dateTime.day().month()
        case .sixMonth, .year: return .dateTime.month()
        }
    }
    
    func calculateWidth(availableWidth: CGFloat) -> CGFloat {
        let count = CGFloat(viewModel.dataPoints.count)
        // Adjust these multipliers to change how "fat" the bars are
        switch viewModel.currentRange {
        case .day: return count * 40
        case .week: return availableWidth // Fit to screen
        case .month: return count * 25
        default: return count * 40
        }
    }
}

