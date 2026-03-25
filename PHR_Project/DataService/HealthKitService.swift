//
//  HealthKitService.swift
//  PHR_Project
//
//  Created by SDC-USER on 20/01/26.
//

import Foundation
import HealthKit

/// Service for fetching health data from Apple HealthKit
final class HealthKitService {

    // MARK: - Singleton

    static let shared = HealthKitService()

    // MARK: - Properties

    private let healthStore = HKHealthStore()

    /// Check if HealthKit is available on this device
    var isHealthKitAvailable: Bool {
        return HKHealthStore.isHealthDataAvailable()
    }

    // MARK: - Init

    private init() {}

    // MARK: - Authorization

    /// - Parameter completion: Callback with success status and optional error
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        guard isHealthKitAvailable else {
            completion(false, HealthKitError.notAvailable)
            return
        }

        // Define the types we want to read
        let typesToRead: Set<HKObjectType> = [
            HKQuantityType.quantityType(forIdentifier: .stepCount)!,
            HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKQuantityType.quantityType(forIdentifier: .bloodGlucose)!,
        ]

        healthStore.requestAuthorization(toShare: nil, read: typesToRead) {
            success,
            error in
            DispatchQueue.main.async {
                completion(success, error)
            }
        }
    }

    // MARK: - Steps

    /// Fetch today's step count
    /// - Parameter completion: Callback with step count or error
    func fetchTodaySteps(completion: @escaping (Result<Int, Error>) -> Void) {
        guard
            let stepType = HKQuantityType.quantityType(
                forIdentifier: .stepCount
            )
        else {
            completion(.failure(HealthKitError.dataTypeNotAvailable))
            return
        }

        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: now,
            options: .strictStartDate
        )

        let query = HKStatisticsQuery(
            quantityType: stepType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { _, result, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let sum = result?.sumQuantity() else {
                    completion(.success(0))
                    return
                }

                let steps = Int(sum.doubleValue(for: HKUnit.count()))
                WidgetDataManager.shared.saveSteps(count: steps)
                completion(.success(steps))
            }
        }

        healthStore.execute(query)
    }

    /// Fetch step count history for a date range
    /// - Parameters:
    ///   - from: Start date
    ///   - to: End date
    ///   - completion: Callback with dictionary of Date: StepCount or error
    func fetchStepHistory(
        from startDate: Date,
        to endDate: Date,
        completion: @escaping (Result<[Date: Int], Error>) -> Void
    ) {
        guard
            let stepType = HKQuantityType.quantityType(
                forIdentifier: .stepCount
            )
        else {
            completion(.failure(HealthKitError.dataTypeNotAvailable))
            return
        }

        let interval = DateComponents(day: 1)
        let query = HKStatisticsCollectionQuery(
            quantityType: stepType,
            quantitySamplePredicate: nil,
            options: .cumulativeSum,
            anchorDate: Calendar.current.startOfDay(for: startDate),
            intervalComponents: interval
        )

        query.initialResultsHandler = { _, results, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }

            var dailySteps: [Date: Int] = [:]
            results?.enumerateStatistics(from: startDate, to: endDate) {
                statistics,
                _ in
                let steps = Int(
                    statistics.sumQuantity()?.doubleValue(for: HKUnit.count())
                        ?? 0
                )
                dailySteps[statistics.startDate] = steps
            }

            DispatchQueue.main.async {
                completion(.success(dailySteps))
            }
        }

        healthStore.execute(query)
    }
}

// MARK: - Errors

enum HealthKitError: LocalizedError {
    case notAvailable
    case dataTypeNotAvailable

    var errorDescription: String? {
        switch self {
        case .notAvailable:
            return "HealthKit is not available on this device"
        case .dataTypeNotAvailable:
            return "The requested health data type is not available"
        }
    }
}
