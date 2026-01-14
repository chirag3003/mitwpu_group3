//
//  WaterIntakeService.swift
//  PHR_Project
//
//  Created by Sushant Pulipati on 13/01/26.
//

import Foundation

class WaterIntakeService {
    static let shared = WaterIntakeService()
    
    // We maintain a local variable for the UI to read instantly
    private var glassCount: Int = 0 {
        didSet {
            // Post notification when water intake changes
            NotificationCenter.default.post(name: NSNotification.Name(NotificationNames.waterIntakeUpdated), object: nil)
            
            // Save to Core Data whenever the variable changes
            save()
        }
    }
    
    private init() {
        loadWaterIntake()
    }
    
    // MARK: - Public Methods
    
    func getGlassCount() -> Int {
        // We check date again just in case the app was left open overnight
        checkIfNewDay()
        return glassCount
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
    
    // Helper to handle "Midnight" edge case
    // If the user leaves the app open overnight, we need to detect the day changed
    private func checkIfNewDay() {
        let calendar = Calendar.current
        
        // If we have a saved record, but that record is NOT from today...
        if let lastRecord = CoreDataManager.shared.fetchWaterIntake(for: Date()) {
            // If the currently loaded glassCount doesn't match the DB, sync them
            // (Usually they match, but this ensures safety)
            if !calendar.isDateInToday(lastRecord.date ?? Date.distantPast) {
                 glassCount = 0 // Reset because the record is old
            }
        } else {
            // If fetch returns nil, it means we haven't created a row for today yet
            // So ensure specific logic handles that if needed,
            // though 'loadWaterIntake' usually handles init.
        }
    }
}
