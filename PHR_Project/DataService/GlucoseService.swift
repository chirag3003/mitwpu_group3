import Foundation

class GlucoseService {
    static let shared = GlucoseService()

    private var readings: [GlucoseReading] = [] {
        didSet {
            NotificationCenter.default.post(
                name: NSNotification.Name(NotificationNames.glucoseUpdated),
                object: nil
            )
        }
    }

    private init() {
        fetchReadings()
    }

    func getReadings() -> [GlucoseReading] {
        return readings
    }

    // MARK: - API Integration

    func fetchReadings() {
        APIService.shared.request(endpoint: "/glucose", method: .get) {
            [weak self] (result: Result<[GlucoseReading], Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let fetchedReadings):
                DispatchQueue.main.async {
                    self.readings = fetchedReadings
                    // Update Widget
                    if let latest = fetchedReadings.sorted(by: {
                        $0.combinedDate < $1.combinedDate
                    }).last {
                        WidgetDataManager.shared.saveGlucose(
                            value: latest.value,
                            date: latest.combinedDate
                        )
                    }
                }
            case .failure(let error):
                print("Error fetching glucose readings: \(error)")
            }
        }
    }

    func addReading(
        _ reading: GlucoseReading,
        completion: @escaping (Result<GlucoseReading, Error>) -> Void
    ) {
        APIService.shared.request(
            endpoint: "/glucose",
            method: .post,
            body: reading
        ) { [weak self] (result: Result<GlucoseReading, Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let savedReading):
                DispatchQueue.main.async {
                    self.readings.append(savedReading)
                    WidgetDataManager.shared.saveGlucose(
                        value: savedReading.value,
                        date: savedReading.combinedDate
                    )
                    completion(.success(savedReading))
                }
            case .failure(let error):
                print("Error adding glucose reading: \(error)")
                completion(.failure(error))
            }
        }
    }

}
