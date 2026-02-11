//
//  WaterIntakeService.swift
//  PHR_Project
//
//  Created by Sushant Pulipati on 13/01/26.
//

import Foundation

class WaterIntakeService {
    static let shared = WaterIntakeService()
    
    // Cache for quick UI access - stores counts by date
    private var waterIntakeCache: [Date: Int] = [:]
    
    // We maintain a local variable for the current day's UI to read instantly
    private var glassCount: Int = 0 {
        didSet {
            // Update cache for today
            let today = Calendar.current.startOfDay(for: Date())
            waterIntakeCache[today] = glassCount
            
            // Post notification when water intake changes
            NotificationCenter.default.post(
                name: NSNotification.Name(NotificationNames.waterIntakeUpdated),
                object: nil
            )
            
            // Save to Core Data whenever the variable changes
            save()
        }
    }
    
    private init() {
        loadWaterIntake()
        loadCachedData()
    }
    
    // MARK: - Public Methods
    
    /// Get glass count for today
    func getGlassCount() -> Int {
        checkIfNewDay()
        return glassCount
    }
    
    /// Get glass count for a specific date
    func getGlassCount(for date: Date) -> Int {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        
        // Check cache first
        if let cachedCount = waterIntakeCache[startOfDay] {
            return cachedCount
        }
        
        // Fetch from Core Data if not cached
        if let entity = CoreDataManager.shared.fetchWaterIntake(for: date) {
            let count = Int(entity.count)
            waterIntakeCache[startOfDay] = count
            return count
        }
        
        return 0
    }
    
    func setGlassCount(_ count: Int) {
        glassCount = max(0, min(10, count)) // Ensure value is between 0 and 10
    }
    
    func incrementGlass() {
        checkIfNewDay()
        if glassCount < 10 {
            glassCount += 1
        }
    }
    
    func decrementGlass() {
        checkIfNewDay()
        if glassCount > 0 {
            glassCount -= 1
        }
    }
    
    /// Increment glass count for a specific date (useful for historical data)
    func incrementGlass(for date: Date) {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        
        // If it's today, use the regular increment
        if calendar.isDateInToday(date) {
            incrementGlass()
            return
        }
        
        // Otherwise, update the specific date
        var currentCount = getGlassCount(for: date)
        if currentCount < 10 {
            currentCount += 1
            waterIntakeCache[startOfDay] = currentCount
            CoreDataManager.shared.saveWaterIntake(count: currentCount, date: date)
        }
    }
    
    /// Decrement glass count for a specific date
    func decrementGlass(for date: Date) {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        
        // If it's today, use the regular decrement
        if calendar.isDateInToday(date) {
            decrementGlass()
            return
        }
        
        // Otherwise, update the specific date
        var currentCount = getGlassCount(for: date)
        if currentCount > 0 {
            currentCount -= 1
            waterIntakeCache[startOfDay] = currentCount
            CoreDataManager.shared.saveWaterIntake(count: currentCount, date: date)
        }
    }
    
    func resetDaily() {
        glassCount = 0
    }
    
    // MARK: - Persistence Logic
    
    private func save() {
        // Save the current count for "Date()" (right now)
        CoreDataManager.shared.saveWaterIntake(count: glassCount, date: Date())
    }
    
    private func loadWaterIntake() {
        // Try to fetch Core Data for Today
        if let entity = CoreDataManager.shared.fetchWaterIntake(for: Date()) {
            self.glassCount = Int(entity.count)
        } else {
            // If no record exists for today, it means it's a new day (or first launch)
            self.glassCount = 0
        }
    }
    
    /// Load recent water intake data into cache (e.g., last 30 days)
    private func loadCachedData() {
        let calendar = Calendar.current
        let today = Date()
        
        // Load last 30 days into cache
        for dayOffset in -15...15 {
            if let date = calendar.date(byAdding: .day, value: dayOffset, to: today) {
                let startOfDay = calendar.startOfDay(for: date)
                
                if let entity = CoreDataManager.shared.fetchWaterIntake(for: date) {
                    waterIntakeCache[startOfDay] = Int(entity.count)
                } else {
                    waterIntakeCache[startOfDay] = 0
                }
            }
        }
    }
    
    /// Refresh cache for date range (call when scrolling in UI)
    func refreshCache(for dates: [Date]) {
        for date in dates {
            let calendar = Calendar.current
            let startOfDay = calendar.startOfDay(for: date)
            
            // Skip if already cached
            if waterIntakeCache[startOfDay] != nil {
                continue
            }
            
            if let entity = CoreDataManager.shared.fetchWaterIntake(for: date) {
                waterIntakeCache[startOfDay] = Int(entity.count)
            } else {
                waterIntakeCache[startOfDay] = 0
            }
        }
    }
    
    // Helper to handle "Midnight" edge case
    // If the user leaves the app open overnight, we need to detect the day changed
    private func checkIfNewDay() {
        let calendar = Calendar.current
        
        // If we have a saved record, but that record is NOT from today...
        if let lastRecord = CoreDataManager.shared.fetchWaterIntake(for: Date()) {
            // If the currently loaded glassCount doesn't match the DB, sync them
            if !calendar.isDateInToday(lastRecord.date ?? Date.distantPast) {
                glassCount = 0 // Reset because the record is old
            } else {
                // Sync with database value if needed
                let dbCount = Int(lastRecord.count)
                if glassCount != dbCount {
                    glassCount = dbCount
                }
            }
        } else {
            // If fetch returns nil, it means we haven't created a row for today yet
            glassCount = 0
        }
    }
}
