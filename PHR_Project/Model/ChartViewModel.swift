//
//  ChartViewModel.swift
//  PHR_Project
//
//  Created by SDC_USER on 20/01/26.
//

import Foundation
import SwiftUI
import Combine
// 1. Define the time ranges
enum ChartTimeRange {
    case day, week, month, sixMonth, year
}

class ChartViewModel: ObservableObject {
    // 2. The data that the chart watches
    @Published var dataPoints: [GlucoseDataPoint] = []
    
    // 3. The current time unit (to format X-axis correctly: hours vs days)
    @Published var currentRange: ChartTimeRange = .week
    
    // 4. Function to generate dummy data based on selection
    func updateData(for range: ChartTimeRange) {
        self.currentRange = range
        var newData: [GlucoseDataPoint] = []
        let today = Date()
        let calendar = Calendar.current
        
        switch range {
        case .day:
            // Generate hourly data for today (e.g., every 4 hours)
            for i in 0..<6 {
                if let date = calendar.date(byAdding: .hour, value: -(i * 4), to: today) {
                    newData.append(GlucoseDataPoint(date: date, value: Int.random(in: 90...130)))
                }
            }
            
        case .week:
            // Generate daily data for last 7 days
            for i in 0..<7 {
                if let date = calendar.date(byAdding: .day, value: -i, to: today) {
                    newData.append(GlucoseDataPoint(date: date, value: Int.random(in: 95...115)))
                }
            }
            
        case .month:
            // Generate daily data for last 30 days
            for i in 0..<30 {
                if let date = calendar.date(byAdding: .day, value: -i, to: today) {
                    newData.append(GlucoseDataPoint(date: date, value: Int.random(in: 85...140)))
                }
            }
            
        default:
            // Simplified for 6M/Year (just some random points)
            for i in 0..<10 {
                if let date = calendar.date(byAdding: .month, value: -i, to: today) {
                    newData.append(GlucoseDataPoint(date: date, value: Int.random(in: 90...120)))
                }
            }
        }
        
        // Sort data by date so the line doesn't zig-zag
        self.dataPoints = newData.sorted { $0.date < $1.date }
    }
}
