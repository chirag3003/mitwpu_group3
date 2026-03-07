//
//  WaterIntakeService.swift
//  PHR_Project
//
//  Created by Sushant Pulipati on 13/01/26.
//

import Foundation

class WaterIntakeService {
    static let shared = WaterIntakeService()

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        return formatter
    }()

    private init() {}
    
    // MARK: - Public Methods
    
    /// Fetch glass count for today
    func fetchGlassCount(completion: @escaping (Int) -> Void) {
        fetchGlassCount(for: Date(), completion: completion)
    }

    /// Fetch glass count for a specific date
    func fetchGlassCount(for date: Date, completion: @escaping (Int) -> Void) {
        // 1. Check if we have a pending update from the Widget for today
        if Calendar.current.isDateInToday(date),
           let widgetData = WidgetDataManager.shared.getWater(),
           widgetData.source == "widget" {
            
            // Sync this widget value TO the server immediately
            // This prevents the server's old value from overwriting the widget's new value
            upsertGlassCount(for: date, glasses: widgetData.count) { syncedCount in
                // After syncing, reset source to "app" so we don't sync again unnecessarily
                WidgetDataManager.shared.saveWater(count: syncedCount, date: date, source: "app")
                completion(syncedCount)
            }
            return
        }

        let dateString = dateFormatter.string(from: date)
        WaterService.shared.fetchByDate(date: dateString) { result in
            switch result {
            case .success(let record):
                if Calendar.current.isDateInToday(date) {
                    WidgetDataManager.shared.saveWater(count: record.glasses)
                }
                completion(record.glasses)
            case .failure(let error):
                print("❌ WaterIntakeService: Failed to fetch water intake - \(error)")
                completion(0)
            }
        }
    }

    func fetchRange(startDate: Date, endDate: Date, completion: @escaping ([WaterRecord]) -> Void) {
        let startString = dateFormatter.string(from: startDate)
        let endString = dateFormatter.string(from: endDate)
        WaterService.shared.fetchRange(startDate: startString, endDate: endString) { result in
            switch result {
            case .success(let records):
                completion(records)
            case .failure(let error):
                print("❌ WaterIntakeService: Failed to fetch water range - \(error)")
                completion([])
            }
        }
    }

    func incrementGlass(completion: @escaping (Int) -> Void) {
        incrementGlass(for: Date(), completion: completion)
    }

    func decrementGlass(completion: @escaping (Int) -> Void) {
        decrementGlass(for: Date(), completion: completion)
    }

    func incrementGlass(for date: Date, completion: @escaping (Int) -> Void) {
        fetchGlassCount(for: date) { [weak self] currentCount in
            guard let self = self else { return }
            if currentCount >= 10 {
                completion(currentCount)
                return
            }
            let newCount = min(currentCount + 1, 10)
            self.upsertGlassCount(for: date, glasses: newCount, completion: completion)
        }
    }

    func decrementGlass(for date: Date, completion: @escaping (Int) -> Void) {
        fetchGlassCount(for: date) { [weak self] currentCount in
            guard let self = self else { return }
            if currentCount <= 0 {
                completion(currentCount)
                return
            }
            let newCount = max(currentCount - 1, 0)
            self.upsertGlassCount(for: date, glasses: newCount, completion: completion)
        }
    }

    private func upsertGlassCount(for date: Date, glasses: Int, completion: @escaping (Int) -> Void) {
        let dateString = dateFormatter.string(from: date)
        WaterService.shared.upsert(dateRecorded: dateString, glasses: glasses) { result in
            switch result {
            case .success(let record):
                NotificationCenter.default.post(
                    name: NSNotification.Name(NotificationNames.waterIntakeUpdated),
                    object: nil
                )
                if Calendar.current.isDateInToday(date) {
                    WidgetDataManager.shared.saveWater(count: record.glasses)
                }
                completion(record.glasses)
            case .failure(let error):
                print("❌ WaterIntakeService: Failed to save water intake - \(error)")
                completion(glasses)
            }
        }
    }
}
