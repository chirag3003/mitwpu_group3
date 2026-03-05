import Foundation

final class SharedDataService {
    static let shared = SharedDataService()

    private init() {}

    struct EmptyResponse: Decodable {}

    func fetchMeals(
        for userId: String,
        completion: @escaping (Result<[Meal], Error>) -> Void
    ) {
        APIService.shared.request(
            endpoint: "/shared/\(userId)/meals",
            method: .get,
            completion: completion
        )
    }

    func deleteMeal(
        for userId: String,
        mealId: String,
        completion: @escaping (Result<EmptyResponse, Error>) -> Void
    ) {
        APIService.shared.request(
            endpoint: "/shared/\(userId)/meals/\(mealId)",
            method: .delete,
            completion: completion
        )
    }

    func fetchGlucoseReadings(
        for userId: String,
        completion: @escaping (Result<[GlucoseReading], Error>) -> Void
    ) {
        APIService.shared.request(
            endpoint: "/shared/\(userId)/glucose",
            method: .get,
            completion: completion
        )
    }

    func fetchSymptoms(
        for userId: String,
        completion: @escaping (Result<[Symptom], Error>) -> Void
    ) {
        APIService.shared.request(
            endpoint: "/shared/\(userId)/symptoms",
            method: .get,
            completion: completion
        )
    }

    func deleteSymptom(
        for userId: String,
        symptomId: String,
        completion: @escaping (Result<EmptyResponse, Error>) -> Void
    ) {
        APIService.shared.request(
            endpoint: "/shared/\(userId)/symptoms/\(symptomId)",
            method: .delete,
            completion: completion
        )
    }

    func fetchDocuments(
        for userId: String,
        completion: @escaping (Result<[Document], Error>) -> Void
    ) {
        APIService.shared.request(
            endpoint: "/shared/\(userId)/documents",
            method: .get,
            completion: completion
        )
    }
}
