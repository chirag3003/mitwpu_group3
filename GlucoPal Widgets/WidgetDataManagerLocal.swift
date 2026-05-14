import Foundation
import WidgetKit

// MARK: - Local Data Manager for Widget
class WidgetDataManagerLocal {

    static let shared = WidgetDataManagerLocal()

    // MARK: - Configuration
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
        static let waterSource = "widget_waterSource"

        static let stepCount = "widget_stepCount"
        static let stepDate = "widget_stepDate"
    }

    // MARK: - Fetch Methods

    // swiftlint:disable:next large_tuple
    func getGlucose() -> (value: Int, date: Date, trend: String)? {
        guard let value = store?.object(forKey: Keys.latestGlucose) as? Int,
            let date = store?.object(forKey: Keys.glucoseDate) as? Date
        else {
            return nil
        }
        let trend = store?.string(forKey: Keys.glucoseTrend) ?? "flat"
        return (value, date, trend)
    }

    // swiftlint:disable:next large_tuple
    func getWater() -> (count: Int, date: Date, source: String)? {
        guard let count = store?.object(forKey: Keys.waterCount) as? Int,
            let date = store?.object(forKey: Keys.waterDate) as? Date
        else {
            return nil
        }

        let source = store?.string(forKey: Keys.waterSource) ?? "app"

        // Reset count if date is not today
        if !Calendar.current.isDateInToday(date) {
            return (0, Date(), "app")
        }

        return (count, date, source)
    }

    func getSteps() -> (count: Int, date: Date)? {
        guard let count = store?.object(forKey: Keys.stepCount) as? Int,
            let date = store?.object(forKey: Keys.stepDate) as? Date
        else {
            return nil
        }

        // Reset count if date is not today
        if !Calendar.current.isDateInToday(date) {
            return (0, Date())
        }

        return (count, date)
    }

    func saveWater(count: Int, date: Date = Date(), source: String = "app") {
        store?.set(count, forKey: Keys.waterCount)
        store?.set(date, forKey: Keys.waterDate)
        store?.set(source, forKey: Keys.waterSource)
        if #available(iOS 14.0, *) {
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
}
