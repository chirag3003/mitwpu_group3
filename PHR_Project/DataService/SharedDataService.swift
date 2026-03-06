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

    func fetchWater(
        for userId: String,
        completion: @escaping (Result<[WaterRecord], Error>) -> Void
    ) {
        APIService.shared.request(
            endpoint: "/shared/\(userId)/water",
            method: .get,
            completion: completion
        )
    }

    func fetchAllergies(
        for userId: String,
        completion: @escaping (Result<[Allergy], Error>) -> Void
    ) {
        APIService.shared.request(
            endpoint: "/shared/\(userId)/allergies",
            method: .get,
            completion: completion
        )
    }

    func addAllergy(
        for userId: String,
        allergy: Allergy,
        completion: @escaping (Result<Allergy, Error>) -> Void
    ) {
        APIService.shared.request(
            endpoint: "/shared/\(userId)/allergies",
            method: .post,
            body: allergy
        ) { (result: Result<Allergy, Error>) in
            switch result {
            case .success:
                NotificationCenter.default.post(
                    name: NSNotification.Name(
                        NotificationNames.sharedAllergiesUpdated
                    ),
                    object: nil,
                    userInfo: ["userId": userId]
                )
            case .failure(let error):
                if case let APIError.httpError(statusCode, message) = error {
                    print(
                        "Shared allergy add failed (\(statusCode)): \(message)"
                    )
                } else {
                    print("Shared allergy add failed: \(error)")
                }
            }
            completion(result)
        }
    }

    func deleteAllergy(
        for userId: String,
        allergyId: String,
        completion: @escaping (Result<EmptyResponse, Error>) -> Void
    ) {
        APIService.shared.request(
            endpoint: "/shared/\(userId)/allergies/\(allergyId)",
            method: .delete
        ) { (result: Result<EmptyResponse, Error>) in
            switch result {
            case .success:
                NotificationCenter.default.post(
                    name: NSNotification.Name(
                        NotificationNames.sharedAllergiesUpdated
                    ),
                    object: nil,
                    userInfo: ["userId": userId]
                )
            case .failure(let error):
                if case let APIError.httpError(statusCode, message) = error {
                    print(
                        "Shared allergy delete failed (\(statusCode)): \(message)"
                    )
                } else {
                    print("Shared allergy delete failed: \(error)")
                }
            }
            completion(result)
        }
    }
}
