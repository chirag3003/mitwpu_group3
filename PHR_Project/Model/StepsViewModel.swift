import Foundation
import HealthKit
import SwiftUI
import Combine

struct StepDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let count: Int
}

class StepsViewModel: ObservableObject {
    @Published var dataPoints: [StepDataPoint] = []
    @Published var todaySteps: Int = 0 // 👈 Dedicated variable for the label
    @Published var currentRange: ChartTimeRange = .week
    
    private let healthStore = HKHealthStore()
    
    func requestAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        healthStore.requestAuthorization(toShare: [], read: [stepType]) { success, error in
            if success {
                DispatchQueue.main.async {
                    self.fetchTodaySteps() // Get the big number immediately
                    self.updateData(for: .week) // Get the graph data
                }
            }
        }
    }
    
    // 1. New Function: Fetch ONLY Today's Steps (Fixes the "Large Value" bug)
    func fetchTodaySteps() {
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            let count = result?.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0
            DispatchQueue.main.async {
                self.todaySteps = Int(count)
            }
        }
        healthStore.execute(query)
    }
    
    // 2. Existing Function: Fetch Graph Data
    func updateData(for range: ChartTimeRange) {
        // Clear data first so user sees it's refreshing
        DispatchQueue.main.async { self.currentRange = range }
        
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let calendar = Calendar.current
        let now = Date()
        
        var startDate: Date
        var interval: DateComponents
        
        // Configure intervals
        switch range {
        case .day:
            startDate = calendar.startOfDay(for: now)
            interval = DateComponents(hour: 1)
        case .week:
            startDate = calendar.date(byAdding: .day, value: -6, to: now)!
            startDate = calendar.startOfDay(for: startDate)
            interval = DateComponents(day: 1)
        case .month:
            startDate = calendar.date(byAdding: .day, value: -29, to: now)!
            startDate = calendar.startOfDay(for: startDate)
            interval = DateComponents(day: 1)
        case .sixMonth:
            startDate = calendar.date(byAdding: .month, value: -6, to: now)!
            startDate = calendar.startOfDay(for: startDate)
            interval = DateComponents(weekOfYear: 1)
        case .year:
            startDate = calendar.date(byAdding: .year, value: -1, to: now)!
            startDate = calendar.startOfDay(for: startDate)
            interval = DateComponents(month: 1)
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: now, options: .strictStartDate)
        
        let query = HKStatisticsCollectionQuery(
            quantityType: stepType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum,
            anchorDate: calendar.startOfDay(for: now),
            intervalComponents: interval
        )
        
        query.initialResultsHandler = { query, results, error in
            guard let statsCollection = results else { return }
            
            var newPoints: [StepDataPoint] = []
            
            statsCollection.enumerateStatistics(from: startDate, to: now) { statistics, stop in
                let count = statistics.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0
                // Only add points that have data (optional, keeps chart clean)
                // if count > 0 {
                    let point = StepDataPoint(date: statistics.startDate, count: Int(count))
                    newPoints.append(point)
                // }
            }
            
            DispatchQueue.main.async {
                self.dataPoints = newPoints
                // Note: We do NOT update 'todaySteps' here anymore
            }
        }
        healthStore.execute(query)
    }
}
