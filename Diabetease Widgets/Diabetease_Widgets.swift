import WidgetKit
import SwiftUI

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
        let glucoseData = WidgetDataManager.shared.getGlucose()
        let waterData = WidgetDataManager.shared.getWater()
        let stepsData = WidgetDataManager.shared.getSteps()
        
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
                Label("\(entry.waterCount)", systemImage: "drop.fill")
                    .font(.caption)
                    .foregroundColor(.blue)
                Spacer()
                Label("\(entry.stepCount)", systemImage: "figure.walk")
                    .font(.caption)
                    .foregroundColor(.green)
            }
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

struct MediumWidgetView: View {
    var entry: HealthEntry
    
    var body: some View {
        HStack(spacing: 20) {
            // Left: Glucose (Big)
            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: "drop.circle.fill")
                        .foregroundColor(.red)
                    Text("Glucose")
                        .font(.headline)
                }
                
                Spacer()
                
                Text("\(entry.glucose)")
                    .font(.system(size: 38, weight: .heavy, design: .rounded))
                Text("mg/dL • \(timeAgo(entry.glucoseDate))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Divider()
            
            // Right: Water & Steps
            VStack(alignment: .leading, spacing: 16) {
                // Water
                HStack {
                    Image(systemName: "drop.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                        .frame(width: 30)
                    VStack(alignment: .leading) {
                        Text("\(entry.waterCount) Glasses")
                            .font(.headline)
                        Text("Hydration")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                // Steps
                HStack {
                    Image(systemName: "figure.walk")
                        .font(.title2)
                        .foregroundColor(.green)
                        .frame(width: 30)
                    VStack(alignment: .leading) {
                        Text("\(entry.stepCount)")
                            .font(.headline)
                        Text("Steps Today")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
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
