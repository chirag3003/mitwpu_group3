import Foundation

class WaterService {
    static let shared = WaterService()

    private init() {}

    func fetchAll(completion: @escaping (Result<[WaterRecord], Error>) -> Void)
    {
        APIService.shared.request(endpoint: "/water", method: .get) {
            (result: Result<[WaterRecord], Error>) in
            completion(result)
        }
    }

    func fetchLatest(completion: @escaping (Result<WaterRecord, Error>) -> Void)
    {
        APIService.shared.request(endpoint: "/water/latest", method: .get) {
            (result: Result<WaterRecord, Error>) in
            completion(result)
        }
    }

    func fetchRange(
        startDate: String,
        endDate: String,
        completion: @escaping (Result<[WaterRecord], Error>) -> Void
    ) {
        let endpoint = "/water/range?startDate=\(startDate)&endDate=\(endDate)"
        APIService.shared.request(endpoint: endpoint, method: .get) {
            (result: Result<[WaterRecord], Error>) in
            completion(result)
        }
    }

    func fetchByDate(
        date: String,
        completion: @escaping (Result<WaterRecord, Error>) -> Void
    ) {
        let endpoint = "/water/date?date=\(date)"
        APIService.shared.request(endpoint: endpoint, method: .get) {
            (result: Result<WaterRecord, Error>) in
            completion(result)
        }
    }

    func fetchById(
        _ id: String,
        completion: @escaping (Result<WaterRecord, Error>) -> Void
    ) {
        APIService.shared.request(endpoint: "/water/\(id)", method: .get) {
            (result: Result<WaterRecord, Error>) in
            completion(result)
        }
    }

    func upsert(
        dateRecorded: String,
        glasses: Int,
        completion: @escaping (Result<WaterRecord, Error>) -> Void
    ) {
        let request = WaterUpsertRequest(
            dateRecorded: dateRecorded,
            glasses: glasses
        )
        APIService.shared.request(
            endpoint: "/water",
            method: .post,
            body: request
        ) { (result: Result<WaterRecord, Error>) in
            completion(result)
        }
    }

    func update(
        id: String,
        dateRecorded: String?,
        glasses: Int?,
        completion: @escaping (Result<WaterRecord, Error>) -> Void
    ) {
        let request = WaterUpdateRequest(
            dateRecorded: dateRecorded,
            glasses: glasses
        )
        APIService.shared.request(
            endpoint: "/water/\(id)",
            method: .put,
            body: request
        ) { (result: Result<WaterRecord, Error>) in
            completion(result)
        }
    }

    func delete(
        id: String,
        completion: @escaping (Result<EmptyResponse, Error>) -> Void
    ) {
        APIService.shared.request(endpoint: "/water/\(id)", method: .delete) {
            (result: Result<EmptyResponse, Error>) in
            completion(result)
        }
    }

    struct EmptyResponse: Decodable {}
}
