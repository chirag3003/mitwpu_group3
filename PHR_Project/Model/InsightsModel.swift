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
