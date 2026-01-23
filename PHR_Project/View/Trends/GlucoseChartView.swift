import Charts
import SwiftUI

struct GlucoseChartView: View {
    @ObservedObject var viewModel: ChartViewModel

    var body: some View {
        if #available(iOS 16.0, *) {
            Chart {
                ForEach(viewModel.dataPoints) { point in

                    AreaMark(
                        x: .value("Time", point.date),
                        yStart: .value("Min", 0), // Explicit anchor
                        yEnd: .value("Value", point.value)
                    )
                    .interpolationMethod(.monotone)
                    .alignsMarkStylesWithPlotArea(true) // Crucial for continuous gradient
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.blue.opacity(0.3),
                                Color.blue.opacity(0.05),
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                    // 2. Update the LineMark
                    LineMark(
                        x: .value("Time", point.date),
                        y: .value("Value", point.value)
                    )
                    .interpolationMethod(.monotone)
                    .lineStyle(StrokeStyle(lineWidth: 3))
                    .foregroundStyle(Color.blue)
                }
            }
            .chartYScale(domain: .automatic)

            //Label format

            .chartXAxis {
                AxisMarks(values: .automatic) { value in
                    AxisGridLine()
                    AxisTick()

                    // Switch logic to format label based on selected Tab
                    switch viewModel.currentRange {
                    case .day:
                        // For Day view, we show Time (e.g., "2 PM")
                        // If we showed "11 Jan", every tick would look identical.
                        AxisValueLabel(format: .dateTime.hour())

                    case .week, .month:
                        // For Week/Month view, we show Date (e.g., "11 Jan")
                        AxisValueLabel(format: .dateTime.day().month())

                    case .sixMonth, .year:
                        // For Year view, we show Month (e.g., "Jan")
                        AxisValueLabel(format: .dateTime.month())
                    }
                }
            }

            .padding()
        } else {
            Text("Charts require iOS 16+")
        }
    }
}
