import WidgetKit
import SwiftUI
import AppIntents

// MARK: - App Intents
struct IncrementWaterIntent: AppIntent {
    static var title: LocalizedStringResource = "Increment Water"
    static var description = IntentDescription("Increments the daily water intake.")

    func perform() async throws -> some IntentResult {
        // Fetch current water count from shared storage
        let currentWater = WidgetDataManagerLocal.shared.getWater()
        let newCount = (currentWater?.count ?? 0) + 1
        
        // Save updated count
        WidgetDataManagerLocal.shared.saveWater(count: newCount, source: "widget")
        
        return .result()
    }
}

struct DecrementWaterIntent: AppIntent {
    static var title: LocalizedStringResource = "Decrement Water"
    static var description = IntentDescription("Decrements the daily water intake.")

    func perform() async throws -> some IntentResult {
        // Fetch current water count from shared storage
        let currentWater = WidgetDataManagerLocal.shared.getWater()
        let currentCount = currentWater?.count ?? 0
        
        // Ensure count doesn't go below 0
        let newCount = max(0, currentCount - 1)
        
        // Save updated count
        WidgetDataManagerLocal.shared.saveWater(count: newCount, source: "widget")
        
        return .result()
    }
}

// MARK: - Timeline Entry
struct HealthEntry: TimelineEntry {
    let date: Date
    let glucose: Int
    let glucoseDate: Date
    let waterCount: Int
    let stepCount: Int
}

// MARK: - Provider
struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> HealthEntry {
        HealthEntry(
            date: Date(),
            glucose: 110,
            glucoseDate: Date(),
            waterCount: 4,
            stepCount: 5430
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (HealthEntry) -> Void) {
        completion(fetchCurrentEntry())
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<HealthEntry>) -> Void) {
        let entry = fetchCurrentEntry()
        // Refresh every 30 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
    
    private func fetchCurrentEntry() -> HealthEntry {
        // Fetch from shared storage
        let glucoseData = WidgetDataManagerLocal.shared.getGlucose()
        let waterData = WidgetDataManagerLocal.shared.getWater()
        let stepsData = WidgetDataManagerLocal.shared.getSteps()
        
        return HealthEntry(
            date: Date(),
            glucose: glucoseData?.value ?? 0,
            glucoseDate: glucoseData?.date ?? Date(),
            waterCount: waterData?.count ?? 0,
            stepCount: stepsData?.count ?? 0
        )
    }
}

// MARK: - Views
struct Diabetease_WidgetsEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        if family == .systemMedium {
            MediumWidgetView(entry: entry)
        } else {
            SmallWidgetView(entry: entry)
        }
    }
}

struct SmallWidgetView: View {
    var entry: HealthEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: "heart.fill")
                    .foregroundColor(.red)
                Text("Vitals")
                    .font(.caption)
                    .bold()
                    .foregroundStyle(.secondary)
            }
            
            // Glucose
            VStack(alignment: .leading, spacing: 2) {
                Text("\(entry.glucose)")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                Text("mg/dL")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Water & Steps Row
            HStack {
                // Interactive Water Button
                Button(intent: IncrementWaterIntent()) {
                    Label("\(entry.waterCount)", systemImage: "drop.fill")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                Label("\(entry.stepCount)", systemImage: "figure.walk")
                    .font(.caption)
                    .foregroundColor(.green)
            }
        }
        .containerBackground(.fill.tertiary, for: .widget)
        // Deep link to Add Meal when tapping the rest of the widget
        .widgetURL(URL(string: "phr://add-meal"))
    }
}

struct MediumWidgetView: View {
    var entry: HealthEntry
    
    var body: some View {
        VStack {
            // MARK: - TOP ROW
            HStack(alignment: .top) {
                // Glucose Section
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Image(systemName: "drop.fill")
                            .font(.caption2)
                            .foregroundColor(.red)
                        Text("GLUCOSE")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundStyle(.secondary)
                    }
                    
                    // Value & Add Button
                    HStack(alignment: .center, spacing: 8) {
                        HStack(alignment: .firstTextBaseline, spacing: 2) {
                            Text("\(entry.glucose)")
                                .font(.system(size: 34, weight: .heavy, design: .rounded))
                                .foregroundColor(.primary)
                            Text("mg/dL")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundStyle(.secondary)
                        }
                        
                        Link(destination: URL(string: "phr://add-glucose")!) {
                            Image(systemName: "plus")
                                .font(.system(size: 14, weight: .bold))
                                .frame(width: 28, height: 28)
                                .background(Color.red.opacity(0.15))
                                .foregroundColor(.red)
                                .clipShape(Circle())
                        }
                    }
                    
                    Text(timeAgo(entry.glucoseDate))
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
                
                Spacer()
                
                // Steps Section
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 4) {
                        Text("STEPS")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundStyle(.secondary)
                        Image(systemName: "figure.walk")
                            .font(.caption2)
                            .foregroundColor(.green)
                    }
                    
                    Text("\(entry.stepCount)")
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .contentTransition(.numericText(value: Double(entry.stepCount)))
                }
            }
            
            Spacer()
            
            // MARK: - BOTTOM ROW
            HStack(alignment: .bottom) {
                // Water Control
                HStack(spacing: 8) {
                    // Stepper Capsule
                    HStack(spacing: 0) {
                        Button(intent: DecrementWaterIntent()) {
                            Image(systemName: "minus")
                                .font(.system(size: 14, weight: .bold))
                                .frame(width: 32, height: 32)
                                .foregroundColor(.blue)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        
                        Text("\(entry.waterCount)")
                            .font(.system(size: 16, weight: .bold))
                            .contentTransition(.numericText(value: Double(entry.waterCount)))
                            .frame(width: 24)
                            .multilineTextAlignment(.center)
                        
                        Button(intent: IncrementWaterIntent()) {
                            Image(systemName: "plus")
                                .font(.system(size: 14, weight: .bold))
                                .frame(width: 32, height: 32)
                                .foregroundColor(.blue)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                    .background(Color.blue.opacity(0.15))
                    .clipShape(Capsule())
                    
                    // Reduced Droplet Image Size
                    Image(systemName: "drop.fill")
                        .font(.subheadline) // Reduced size
                        .foregroundColor(.blue.opacity(0.7))
                }
                .padding(.bottom, 2)
                
                Spacer()
                
                // MARK: - Meals Section
                VStack(alignment: .trailing, spacing: 6) {
                    // Title perfectly matches the "STEPS" title format above it
                    HStack(spacing: 4) {
                        Text("MEALS")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundStyle(.secondary)
                        Image(systemName: "fork.knife")
                            .font(.caption2)
                            .foregroundColor(.orange)
                    }
                    
                    HStack(spacing: 12) {
                        Link(destination: URL(string: "phr://add-meal")!) {
                            Image(systemName: "fork.knife")
                                .font(.system(size: 14, weight: .semibold))
                                .frame(width: 36, height: 36)
                                .background(Color.orange.opacity(0.15))
                                .foregroundColor(.orange)
                                .clipShape(Circle())
                        }
                        
                        Link(destination: URL(string: "phr://add-meal?camera=true")!) {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 14, weight: .semibold))
                                .frame(width: 36, height: 36)
                                .background(Color.gray.opacity(0.15))
                                .foregroundColor(.primary)
                                .clipShape(Circle())
                        }
                    }
                }
            }
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 2)
        .containerBackground(.fill.tertiary, for: .widget)
    }
    
    private func timeAgo(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Widget Configuration
struct Diabetease_Widgets: Widget {
    let kind: String = "Diabetease_Widgets"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            Diabetease_WidgetsEntryView(entry: entry)
        }
        .configurationDisplayName("Daily Vitals")
        .description("Track your Glucose, Water, and Steps at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemMedium) {
    Diabetease_Widgets()
} timeline: {
    HealthEntry(
        date: .now,
        glucose: 120,
        glucoseDate: .now,
        waterCount: 5,
        stepCount: 8500
    )
}

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
    
    func getGlucose() -> (value: Int, date: Date, trend: String)? {
        guard let value = store?.object(forKey: Keys.latestGlucose) as? Int,
              let date = store?.object(forKey: Keys.glucoseDate) as? Date else {
            return nil
        }
        let trend = store?.string(forKey: Keys.glucoseTrend) ?? "flat"
        return (value, date, trend)
    }
    
    func getWater() -> (count: Int, date: Date, source: String)? {
        guard let count = store?.object(forKey: Keys.waterCount) as? Int,
              let date = store?.object(forKey: Keys.waterDate) as? Date else {
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
              let date = store?.object(forKey: Keys.stepDate) as? Date else {
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
