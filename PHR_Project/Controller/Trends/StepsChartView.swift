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
                        Chart {
                            ForEach(viewModel.dataPoints) { point in
                                
                                // ⚡️ FIX: Determine bar width unit based on range
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
                        .id(viewModel.currentRange) // Force redraw on change
                        .frame(width: max(geometry.size.width, calculateWidth(availableWidth: geometry.size.width)))
                        .id("ChartEnd")
                        
                        .chartXAxis {
                            AxisMarks(values: .automatic) { _ in
                                AxisTick()
                                AxisValueLabel(format: xAxisFormat(), centered: true)
                            }
                        }
                        .padding(.top)
                    }
                    .onChange(of: viewModel.currentRange) { _ in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation {
                                scrollProxy.scrollTo("ChartEnd", anchor: .trailing)
                            }
                        }
                    }
                }
            }
        } else {
            Text("iOS 16+ Required")
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
    
    func calculateWidth(availableWidth: CGFloat) -> CGFloat {
        let count = CGFloat(viewModel.dataPoints.count)
        switch viewModel.currentRange {
        case .day: return count * 40
        case .week: return availableWidth
        case .month: return count * 20
        case .sixMonth: return count * 30
        case .year: return availableWidth
        }
    }
}
