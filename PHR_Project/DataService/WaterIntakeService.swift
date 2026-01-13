//
//  WaterIntakeService.swift
//  PHR_Project
//
//  Created by Sushant Pulipati on 13/01/26.
//

import Foundation

class WaterIntakeService {
    static let shared = WaterIntakeService()
    private let storageKey = StorageKeys.waterIntake
    
    private var glassCount: Int = 0 {
        didSet {
            save()
            // Post notification when water intake changes
            NotificationCenter.default.post(name: NSNotification.Name(NotificationNames.waterIntakeUpdated), object: nil)
        }
    }
    
    private init() {
        loadWaterIntake()
    }
    
    // MARK: - Public Methods
    
    func getGlassCount() -> Int {
        return glassCount
    }
    
    func setGlassCount(_ count: Int) {
        glassCount = max(0, min(10, count)) // Ensure value is between 0 and 10
    }
    
    func incrementGlass() {
        if glassCount < 10 {
            glassCount += 1
        }
    }
    
    func decrementGlass() {
        if glassCount > 0 {
            glassCount -= 1
        }
    }
    
    func resetDaily() {
        glassCount = 0
    }
    
    // MARK: - Persistence Logic
    
    private func save() {
        UserDefaults.standard.set(glassCount, forKey: storageKey)
    }
    
    private func loadWaterIntake() {
        glassCount = UserDefaults.standard.integer(forKey: storageKey)
    }
}
