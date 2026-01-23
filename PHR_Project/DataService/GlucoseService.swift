import Foundation

class GlucoseService {
    static let shared = GlucoseService()
    
    private var readings: [GlucoseReading] = [] {
        didSet {
            NotificationCenter.default.post(name: NSNotification.Name(NotificationNames.glucoseUpdated), object: nil)
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
        APIService.shared.request(endpoint: "/glucose", method: .get) { [weak self] (result: Result<[GlucoseReading], Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let fetchedReadings):
                DispatchQueue.main.async {
                    self.readings = fetchedReadings
                }
            case .failure(let error):
                print("Error fetching glucose readings: \(error)")
            }
        }
    }
    
    func addReading(_ reading: GlucoseReading, completion: @escaping (Result<GlucoseReading, Error>) -> Void) {
        APIService.shared.request(endpoint: "/glucose", method: .post, body: reading) { [weak self] (result: Result<GlucoseReading, Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let savedReading):
                DispatchQueue.main.async {
                    self.readings.append(savedReading)
                    completion(.success(savedReading))
                }
            case .failure(let error):
                print("Error adding glucose reading: \(error)")
                completion(.failure(error))
            }
        }
    }
    
    func deleteReading(id: String, completion: @escaping (Result<Void, Error>) -> Void) {
        // Optimistic Delete
        if let index = readings.firstIndex(where: { $0.id == id }) {
            readings.remove(at: index)
        }
        
        APIService.shared.request(endpoint: "/glucose/\(id)", method: .delete) { (result: Result<EmptyResponse, Error>) in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    completion(.success(()))
                }
            case .failure(let error):
                print("Error deleting glucose reading: \(error)")
                // Re-fetch or handle rollback if needed
                completion(.failure(error))
            }
        }
    }
    
    func fetchStats(startDate: String, endDate: String, completion: @escaping (Result<GlucoseStats, Error>) -> Void) {
        let endpoint = "/glucose/stats?startDate=\(startDate)&endDate=\(endDate)"
        APIService.shared.request(endpoint: endpoint, method: .get) { (result: Result<GlucoseStats, Error>) in
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
    
    // Helper used in deletion
    struct EmptyResponse: Decodable {}
}
