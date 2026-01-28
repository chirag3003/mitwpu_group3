//
//  InsightsService.swift
//  PHR_Project
//
//  Created by SDC-USER on 28/01/26.
//

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

// MARK: - Insights Service

class InsightsService {
    
    static let shared = InsightsService()
    
    private init() {}
    
    // MARK: - Cached Data
    
    private var cachedMealInsights: MealInsightsResponse?
    private var cachedGlucoseInsights: GlucoseInsightsResponse?
    private var mealInsightsCacheTime: Date?
    private var glucoseInsightsCacheTime: Date?
    
    // Cache duration: 30 minutes (insights don't change frequently)
    private let cacheDuration: TimeInterval = 30 * 60
    
    // MARK: - Public Methods
    
    /// Fetch meal insights from API
    /// - Parameters:
    ///   - forceRefresh: If true, bypass cache and fetch fresh data
    ///   - completion: Callback with optional MealInsightsResponse
    func fetchMealInsights(forceRefresh: Bool = false, completion: @escaping (MealInsightsResponse?) -> Void) {
        // Check cache first
        if !forceRefresh, let cached = cachedMealInsights, let cacheTime = mealInsightsCacheTime {
            if Date().timeIntervalSince(cacheTime) < cacheDuration {
                completion(cached)
                return
            }
        }
        
        APIService.shared.get(endpoint: "/insights/meals") { [weak self] (result: Result<MealInsightsResponse, APIError>) in
            switch result {
            case .success(let response):
                self?.cachedMealInsights = response
                self?.mealInsightsCacheTime = Date()
                completion(response)
                
            case .failure(let error):
                print("❌ InsightsService: Failed to fetch meal insights - \(error)")
                completion(nil)
            }
        }
    }
    
    /// Fetch glucose insights from API
    /// - Parameters:
    ///   - forceRefresh: If true, bypass cache and fetch fresh data
    ///   - completion: Callback with optional GlucoseInsightsResponse
    func fetchGlucoseInsights(forceRefresh: Bool = false, completion: @escaping (GlucoseInsightsResponse?) -> Void) {
        // Check cache first
        if !forceRefresh, let cached = cachedGlucoseInsights, let cacheTime = glucoseInsightsCacheTime {
            if Date().timeIntervalSince(cacheTime) < cacheDuration {
                completion(cached)
                return
            }
        }
        
        APIService.shared.get(endpoint: "/insights/glucose") { [weak self] (result: Result<GlucoseInsightsResponse, APIError>) in
            switch result {
            case .success(let response):
                self?.cachedGlucoseInsights = response
                self?.glucoseInsightsCacheTime = Date()
                completion(response)
                
            case .failure(let error):
                print("❌ InsightsService: Failed to fetch glucose insights - \(error)")
                completion(nil)
            }
        }
    }
    
    /// Get cached meal insights (if available)
    func getCachedMealInsights() -> MealInsightsResponse? {
        return cachedMealInsights
    }
    
    /// Get cached glucose insights (if available)
    func getCachedGlucoseInsights() -> GlucoseInsightsResponse? {
        return cachedGlucoseInsights
    }
    
    /// Clear all cached insights
    func clearCache() {
        cachedMealInsights = nil
        cachedGlucoseInsights = nil
        mealInsightsCacheTime = nil
        glucoseInsightsCacheTime = nil
    }
}
