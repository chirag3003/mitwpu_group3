import Foundation

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
    func fetchMealInsights(
        forceRefresh: Bool = false,
        completion: @escaping (MealInsightsResponse?) -> Void
    ) {
        // Check cache first
        if !forceRefresh, let cached = cachedMealInsights,
            let cacheTime = mealInsightsCacheTime
        {
            if Date().timeIntervalSince(cacheTime) < cacheDuration {
                completion(cached)
                return
            }
        }

        APIService.shared.request(endpoint: "/insights/meals", method: .get) {
            [weak self] (result: Result<MealInsightsResponse, Error>) in
            switch result {
            case .success(let response):
                self?.cachedMealInsights = response
                self?.mealInsightsCacheTime = Date()
                completion(response)

            case .failure(let error):
                print(
                    "❌ InsightsService: Failed to fetch meal insights - \(error)"
                )
                completion(nil)
            }
        }
    }

    /// Fetch glucose insights from API
    /// - Parameters:
    ///   - forceRefresh: If true, bypass cache and fetch fresh data
    ///   - completion: Callback with optional GlucoseInsightsResponse
    func fetchGlucoseInsights(
        forceRefresh: Bool = false,
        completion: @escaping (GlucoseInsightsResponse?) -> Void
    ) {
        // Check cache first
        if !forceRefresh, let cached = cachedGlucoseInsights,
            let cacheTime = glucoseInsightsCacheTime
        {
            if Date().timeIntervalSince(cacheTime) < cacheDuration {
                completion(cached)
                return
            }
        }

        APIService.shared.request(endpoint: "/insights/glucose", method: .get) {
            [weak self] (result: Result<GlucoseInsightsResponse, Error>) in
            switch result {
            case .success(let response):
                self?.cachedGlucoseInsights = response
                self?.glucoseInsightsCacheTime = Date()
                completion(response)

            case .failure(let error):
                print(
                    "❌ InsightsService: Failed to fetch glucose insights - \(error)"
                )
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
