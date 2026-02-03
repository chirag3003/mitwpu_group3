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
                completion(.success(steps))
            }
        }

        healthStore.execute(query)
    }

    // MARK: - Calories

    /// Fetch today's active calories burned
    /// - Parameter completion: Callback with calories or error
    func fetchTodayCalories(
        completion: @escaping (Result<Double, Error>) -> Void
    ) {
        guard
            let calorieType = HKQuantityType.quantityType(
                forIdentifier: .activeEnergyBurned
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
            quantityType: calorieType,
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

                let calories = sum.doubleValue(for: HKUnit.kilocalorie())
                completion(.success(calories))
            }
        }

        healthStore.execute(query)
    }

    // MARK: - Blood Glucose

    /// Fetch the latest blood glucose reading
    /// - Parameter completion: Callback with glucose value in mg/dL or error
    func fetchLatestBloodGlucose(
        completion: @escaping (Result<Double?, Error>) -> Void
    ) {
        guard
            let glucoseType = HKQuantityType.quantityType(
                forIdentifier: .bloodGlucose
            )
        else {
            completion(.failure(HealthKitError.dataTypeNotAvailable))
            return
        }

        let sortDescriptor = NSSortDescriptor(
            key: HKSampleSortIdentifierStartDate,
            ascending: false
        )

        let query = HKSampleQuery(
            sampleType: glucoseType,
            predicate: nil,
            limit: 1,
            sortDescriptors: [sortDescriptor]
        ) { _, samples, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let sample = samples?.first as? HKQuantitySample else {
                    completion(.success(nil))
                    return
                }

                // Convert to mg/dL
                let glucoseUnit = HKUnit(from: "mg/dL")
                let value = sample.quantity.doubleValue(for: glucoseUnit)
                completion(.success(value))
            }
        }

        healthStore.execute(query)
    }
}

// MARK: - Errors

enum HealthKitError: LocalizedError {
    case notAvailable
    case dataTypeNotAvailable
    case authorizationDenied

    var errorDescription: String? {
        switch self {
        case .notAvailable:
            return "HealthKit is not available on this device"
        case .dataTypeNotAvailable:
            return "The requested health data type is not available"
        case .authorizationDenied:
            return "Authorization to access health data was denied"
        }
    }
}
