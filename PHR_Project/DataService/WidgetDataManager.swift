import Foundation
import WidgetKit

/// Manages data sharing between the main app and the widget using App Groups.
///
/// **Setup Required:**
/// 1. Add the "App Groups" capability to your Main App Target.
/// 2. Add the "App Groups" capability to your Widget Extension Target.
/// 3. Create a group ID "group.codes.chirag.phrios" and check it in both targets.
/// 4. Add this file to BOTH targets in Xcode (File Inspector -> Target Membership).
class WidgetDataManager {
    
    static let shared = WidgetDataManager()
    
    // MARK: - Configuration
    // Replace this with your actual App Group ID from Xcode
    private let appGroupID = "group.codes.chirag.phrios"
    
    private let suiteName: String
    
    private init() {
        self.suiteName = appGroupID
    }
    
    private var store: UserDefaults? {
        return UserDefaults(suiteName: suiteName)
    }
    
    // MARK: - Keys
    private enum Keys {
        static let latestGlucose = "widget_latestGlucose"
        static let glucoseDate = "widget_glucoseDate"
        static let glucoseTrend = "widget_glucoseTrend"
        
        static let waterCount = "widget_waterCount"
        static let waterDate = "widget_waterDate"
        
        static let stepCount = "widget_stepCount"
        static let stepDate = "widget_stepDate"
    }
    
    // MARK: - Public Methods
    
    func saveGlucose(value: Int, date: Date, trend: String = "flat") {
        store?.set(value, forKey: Keys.latestGlucose)
        store?.set(date, forKey: Keys.glucoseDate)
        store?.set(trend, forKey: Keys.glucoseTrend)
        reloadWidgets()
    }
    
    func saveWater(count: Int, date: Date = Date()) {
        store?.set(count, forKey: Keys.waterCount)
        store?.set(date, forKey: Keys.waterDate)
        reloadWidgets()
    }
    
    func saveSteps(count: Int, date: Date = Date()) {
        store?.set(count, forKey: Keys.stepCount)
        store?.set(date, forKey: Keys.stepDate)
        reloadWidgets()
    }
    
    // MARK: - Fetch Methods (For Widget)
    
    func getGlucose() -> (value: Int, date: Date, trend: String)? {
        guard let value = store?.object(forKey: Keys.latestGlucose) as? Int,
              let date = store?.object(forKey: Keys.glucoseDate) as? Date else {
            return nil
        }
        let trend = store?.string(forKey: Keys.glucoseTrend) ?? "flat"
        return (value, date, trend)
    }
    
    func getWater() -> (count: Int, date: Date)? {
        guard let count = store?.object(forKey: Keys.waterCount) as? Int,
              let date = store?.object(forKey: Keys.waterDate) as? Date else {
            return nil
        }
        
        // Reset count if date is not today
        if !Calendar.current.isDateInToday(date) {
            return (0, Date())
        }
        
        return (count, date)
    }
    
    func getSteps() -> (count: Int, date: Date)? {
        guard let count = store?.object(forKey: Keys.stepCount) as? Int,
              let date = store?.object(forKey: Keys.stepDate) as? Date else {
            return nil
        }
        
        // Reset count if date is not today
        if !Calendar.current.isDateInToday(date) {
            return (0, Date())
        }
        
        return (count, date)
    }
    
    // MARK: - Helpers
    
    private func reloadWidgets() {
        if #available(iOS 14.0, *) {
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
}
