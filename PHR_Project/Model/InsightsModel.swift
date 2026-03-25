import UIKit

// MARK: - Meal Insights Models
struct MealInsightsResponse: Codable {
    let insights: [MealInsight]
    let tips: [MealTip]
    let summary: String
}

struct MealInsight: Codable {
    let title: String
    let description: String
    let type: InsightType
}

struct MealTip: Codable {
    let title: String
    let description: String
    let priority: TipPriority
}

enum InsightType: String, Codable {
    case positive
    case warning
    case info
    
    var color: UIColor {
        switch self {
        case .positive: return .systemGreen
        case .warning: return .systemOrange
        case .info: return .systemBlue
        }
    }
}

// MARK: - Glucose Insights Models

struct GlucoseInsightsResponse: Codable {
    let insights: [GlucoseInsight]
    let patterns: [GlucosePattern]
    let tips: [GlucoseTip]
    let summary: String
}

struct GlucoseInsight: Codable {
    let title: String
    let description: String
    let type: GlucoseInsightType
}

struct GlucosePattern: Codable {
    let pattern: String
    let frequency: String
    let recommendation: String
}

struct GlucoseTip: Codable {
    let title: String
    let description: String
    let priority: TipPriority
}

enum GlucoseInsightType: String, Codable {
    case positive
    case warning
    case info
    case critical
    
    var color: UIColor {
        switch self {
        case .positive: return .systemGreen
        case .warning: return .systemOrange
        case .info: return .systemBlue
        case .critical: return .systemRed
        }
    }
}

enum TipPriority: String, Codable {
    case high
    case medium
    case low
    
    var color: UIColor {
        switch self {
        case .high: return .systemRed
        case .medium: return .systemOrange
        case .low: return .systemGray
        }
    }
}

// MARK: - Summary Models

struct SummaryRequest: Codable {
    let startDate: String
    let endDate: String
    let include: SummaryInclude
}

struct SummaryInclude: Codable {
    let glucose: Bool
    let symptoms: Bool
    let meals: Bool
    let documents: Bool
    let activity: Bool
}

struct SummaryResponse: Codable {
    let url: String
}

// MARK: - Water Insights Models
// ... (rest of the file)
// Add these at the end
// MARK: - Activity Insights Models

struct ActivityInsightsResponse: Codable {
    let insights: [ActivityInsight]
    let tips: [ActivityTip]
    let summary: String
    let correlations: [ActivityCorrelation]?
}

struct ActivityInsight: Codable {
    let title: String
    let description: String
    let type: InsightType
}

struct ActivityTip: Codable {
    let title: String
    let description: String
    let priority: TipPriority
}

struct ActivityCorrelation: Codable {
    let title: String
    let value: String
    let trend: CorrelationTrend
}

enum CorrelationTrend: String, Codable {
    case positive
    case negative
    case neutral
}

struct WaterInsightsResponse: Codable {
    let insights: [WaterInsight]
    let tips: [WaterTip]
    let summary: String
}

struct WaterInsight: Codable {
    let title: String
    let description: String
    let type: InsightType
}

struct WaterTip: Codable {
    let title: String
    let description: String
    let priority: TipPriority
}
