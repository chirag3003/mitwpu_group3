import Foundation
import HealthKit
import SwiftUI
import Combine


enum StepsTimeRange: Int {
    case day = 0
    case week = 1
    case month = 2
    case sixMonth = 3
    case year = 4
}

struct StepDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let count: Int
}

class StepsViewModel: ObservableObject {
    @Published var dataPoints: [StepDataPoint] = []
    @Published var mainStatValue: String = "0"
    @Published var mainStatTitle: String = "Total"
    @Published var currentRange: StepsTimeRange = .day // ⚡️ Updated type
    
    private let healthStore = HKHealthStore()
    
    func requestAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        healthStore.requestAuthorization(toShare: [], read: [stepType]) { success, error in
            if success {
                DispatchQueue.main.async {
                    self.updateData(for: .day)
                }
            }
        }
    }
    
   // use of stepsTimeChange enum
    
    func updateData(for range: StepsTimeRange) {
        DispatchQueue.main.async { self.currentRange = range }
        
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let calendar = Calendar.current
        let now = Date()
        var startDate: Date
        var interval: DateComponents
        var anchorDate: Date
        
        switch range {
        case .day:
            startDate = calendar.startOfDay(for: now)
            interval = DateComponents(hour: 1)
            anchorDate = calendar.startOfDay(for: now)
            
        case .week:
            startDate = calendar.date(byAdding: .day, value: -6, to: now)!
            startDate = calendar.startOfDay(for: startDate)
            interval = DateComponents(day: 1)
            anchorDate = calendar.startOfDay(for: now)
            
        case .month:
            startDate = calendar.date(byAdding: .day, value: -29, to: now)!
            startDate = calendar.startOfDay(for: startDate)
            interval = DateComponents(day: 1)
            anchorDate = calendar.startOfDay(for: now)
            
        case .sixMonth:
            let sixMonthsAgo = calendar.date(byAdding: .month, value: -6, to: now)!
            startDate = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: sixMonthsAgo)) ?? sixMonthsAgo
            interval = DateComponents(weekOfYear: 1)
            
            let weekday = calendar.component(.weekday, from: now)
            let daysToSubtract = (weekday - calendar.firstWeekday + 7) % 7
            anchorDate = calendar.date(byAdding: .day, value: -daysToSubtract, to: calendar.startOfDay(for: now))!
            
        case .year:
            let oneYearAgo = calendar.date(byAdding: .year, value: -1, to: now)!
            startDate = calendar.date(from: calendar.dateComponents([.year, .month], from: oneYearAgo)) ?? oneYearAgo
            interval = DateComponents(month: 1)
            
            let components = calendar.dateComponents([.year, .month], from: now)
            anchorDate = calendar.date(from: components)!
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: now, options: .strictStartDate)
        
        let query = HKStatisticsCollectionQuery(
            quantityType: stepType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum,
            anchorDate: anchorDate,
            intervalComponents: interval
        )
        
        query.initialResultsHandler = { query, results, error in
            guard let statsCollection = results else { return }
            
          

            var newPoints: [StepDataPoint] = []
            var totalStepsInPeriod: Double = 0

            statsCollection.enumerateStatistics(from: startDate, to: now) { statistics, stop in
                let count = statistics.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0
                
                // Keep 'count' as a Double for the running total
                totalStepsInPeriod += count
                
                // It is okay to cast to Int for the individual graph bar
                let point = StepDataPoint(date: statistics.startDate, count: Int(count))
                newPoints.append(point)
            }

            DispatchQueue.main.async {
                self.dataPoints = newPoints
                
                if range == .day {
                    self.mainStatTitle = "Total"
                    // 3. Round and Int cast at the VERY END
                    self.mainStatValue = "\(Int(totalStepsInPeriod.rounded()))"
                } else {
                    self.mainStatTitle = "Daily Average"
                    let daysInPeriod = calendar.dateComponents([.day], from: startDate, to: now).day ?? 1
                    
                    // average calculation
                    let average = daysInPeriod > 0 ? Int((totalStepsInPeriod / Double(daysInPeriod)).rounded()) : 0
                    self.mainStatValue = "\(average)"
                }
            }
        }
        healthStore.execute(query)
    }
}
