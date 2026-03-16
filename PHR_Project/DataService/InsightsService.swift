import Foundation

// MARK: - Insights Service

class InsightsService {

    static let shared = InsightsService()

    private init() {}

    // MARK: - Cached Data

    private var cachedMealInsights: MealInsightsResponse?
    private var cachedGlucoseInsights: GlucoseInsightsResponse?
    private var cachedWaterInsights: WaterInsightsResponse?
    private var cachedSharedGlucoseInsights: [String: GlucoseInsightsResponse] =
        [:]
    private var cachedSharedWaterInsights: [String: WaterInsightsResponse] = [:]
    private var mealInsightsCacheTime: Date?
    private var glucoseInsightsCacheTime: Date?
    private var waterInsightsCacheTime: Date?
    private var sharedGlucoseInsightsCacheTime: [String: Date] = [:]
    private var sharedWaterInsightsCacheTime: [String: Date] = [:]

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

    func fetchSharedMealInsights(
        userId: String,
        forceRefresh: Bool = false,
        completion: @escaping (MealInsightsResponse?) -> Void
    ) {
        if !forceRefresh,
            let cached = cachedMealInsights,
            let cacheTime = mealInsightsCacheTime
        {
            if Date().timeIntervalSince(cacheTime) < cacheDuration {
                completion(cached)
                return
            }
        }

        APIService.shared.request(
            endpoint: "/shared/\(userId)/insights/meals",
            method: .get
        ) { [weak self] (result: Result<MealInsightsResponse, Error>) in
            switch result {
            case .success(let response):
                self?.cachedMealInsights = response
                self?.mealInsightsCacheTime = Date()
                completion(response)
            case .failure(let error):
                print(
                    "❌ InsightsService: Failed to fetch shared meal insights - \(error)"
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

    func fetchSharedGlucoseInsights(
        userId: String,
        forceRefresh: Bool = false,
        completion: @escaping (GlucoseInsightsResponse?) -> Void
    ) {
        if !forceRefresh,
            let cached = cachedSharedGlucoseInsights[userId],
            let cacheTime = sharedGlucoseInsightsCacheTime[userId]
        {
            if Date().timeIntervalSince(cacheTime) < cacheDuration {
                completion(cached)
                return
            }
        }

        APIService.shared.request(
            endpoint: "/shared/\(userId)/insights/glucose",
            method: .get
        ) { [weak self] (result: Result<GlucoseInsightsResponse, Error>) in
            switch result {
            case .success(let response):
                self?.cachedSharedGlucoseInsights[userId] = response
                self?.sharedGlucoseInsightsCacheTime[userId] = Date()
                completion(response)
            case .failure(let error):
                print(
                    "❌ InsightsService: Failed to fetch shared glucose insights - \(error)"
                )
                completion(nil)
            }
        }
    }

    /// Fetch water intake insights from API
    /// - Parameters:
    ///   - forceRefresh: If true, bypass cache and fetch fresh data
    ///   - completion: Callback with optional WaterInsightsResponse
    func fetchWaterInsights(
        forceRefresh: Bool = false,
        completion: @escaping (WaterInsightsResponse?) -> Void
    ) {
        if !forceRefresh, let cached = cachedWaterInsights,
            let cacheTime = waterInsightsCacheTime
        {
            if Date().timeIntervalSince(cacheTime) < cacheDuration {
                completion(cached)
                return
            }
        }

        APIService.shared.request(endpoint: "/insights/water", method: .get) {
            [weak self] (result: Result<WaterInsightsResponse, Error>) in
            switch result {
            case .success(let response):
                self?.cachedWaterInsights = response
                self?.waterInsightsCacheTime = Date()
                completion(response)
            case .failure(let error):
                print(
                    "❌ InsightsService: Failed to fetch water insights - \(error)"
                )
                completion(nil)
            }
        }
    }

    func fetchSharedWaterInsights(
        userId: String,
        forceRefresh: Bool = false,
        completion: @escaping (WaterInsightsResponse?) -> Void
    ) {
        if !forceRefresh,
            let cached = cachedSharedWaterInsights[userId],
            let cacheTime = sharedWaterInsightsCacheTime[userId]
        {
            if Date().timeIntervalSince(cacheTime) < cacheDuration {
                completion(cached)
                return
            }
        }

        APIService.shared.request(
            endpoint: "/shared/\(userId)/insights/water",
            method: .get
        ) { [weak self] (result: Result<WaterInsightsResponse, Error>) in
            switch result {
            case .success(let response):
                self?.cachedSharedWaterInsights[userId] = response
                self?.sharedWaterInsightsCacheTime[userId] = Date()
                completion(response)
            case .failure(let error):
                print(
                    "❌ InsightsService: Failed to fetch shared water insights - \(error)"
                )
                completion(nil)
            }
        }
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
                print(
                    "✅ InsightsService: Summary generated successfully - \(response)"
                )
                completion(response.url)
            case .failure(let error):
                print(
                    "❌ InsightsService: Failed to generate summary - \(error)"
                )
                completion(nil)
            }
        }
    }

    func generateSharedSummary(
        for userId: String,
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
            endpoint: "/shared/\(userId)/insights/summary",
            method: .post,
            body: request
        ) { (result: Result<SummaryResponse, Error>) in
            switch result {
            case .success(let response):
                print(
                    "✅ InsightsService: Shared summary generated successfully - \(response)"
                )
                completion(response.url)
            case .failure(let error):
                print(
                    "❌ InsightsService: Failed to generate shared summary - \(error)"
                )
                completion(nil)
            }
        }
    }
}
