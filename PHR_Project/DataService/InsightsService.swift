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
    
    // MARK: - Summary Generation
    
    /// Generate a comprehensive PDF health summary via API
    /// - Parameters:
    ///   - startDate: Start of date range
    ///   - endDate: End of date range
    ///   - include: Which data sections to include
    ///   - completion: Callback with the PDF URL string or nil on failure
    func generateSummary(
        startDate: Date,
        endDate: Date,
        include: SummaryInclude,
        completion: @escaping (String?) -> Void
    ) {
        let formatter = ISO8601DateFormatter()
        let request = SummaryRequest(
            startDate: formatter.string(from: startDate),
            endDate: formatter.string(from: endDate),
            include: include
        )
        
        APIService.shared.request(
            endpoint: "/insights/summary",
            method: .post,
            body: request
        ) { (result: Result<SummaryResponse, Error>) in
            switch result {
            case .success(let response):
                print("✅ InsightsService: Summary generated successfully - \(response)")
                completion(response.url)
            case .failure(let error):
                print("❌ InsightsService: Failed to generate summary - \(error)")
                completion(nil)
            }
        }
    }
}
