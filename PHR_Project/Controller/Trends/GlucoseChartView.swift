//
//  GlucoseChartView.swift
//  PHR_Project
//
//  Created by SDC_USER on 20/01/26.
//

import SwiftUI
import Charts

struct GlucoseChartView: View {
    @ObservedObject var viewModel: ChartViewModel
    
    var body: some View {
        if #available(iOS 16.0, *) {
            Chart {
                ForEach(viewModel.dataPoints) { point in
                    
                    // 1. Dynamic Unit: Hour for Day View, Day for others
                    let xUnit: Calendar.Component = (viewModel.currentRange == .day) ? .hour : .day
                    
                    AreaMark(
                        x: .value("Time", point.date, unit: xUnit),
                        y: .value("Value", point.value)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue.opacity(0.3), .blue.opacity(0.0)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    
                    LineMark(
                        x: .value("Time", point.date, unit: xUnit),
                        y: .value("Value", point.value)
                    )
                    .interpolationMethod(.catmullRom)
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
