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

    func addMeal(
        for userId: String,
        meal: Meal,
        completion: @escaping (Result<Meal, Error>) -> Void
    ) {
        APIService.shared.request(
            endpoint: "/shared/\(userId)/meals",
            method: .post,
            body: meal
        ) { (result: Result<Meal, Error>) in
            if case .success = result {
                NotificationCenter.default.post(
                    name: NSNotification.Name(NotificationNames.mealsUpdated),
                    object: nil
                )
            }
            completion(result)
        }
    }

    func updateMeal(
        for userId: String,
        mealId: String,
        meal: Meal,
        completion: @escaping (Result<Meal, Error>) -> Void
    ) {
        APIService.shared.request(
            endpoint: "/shared/\(userId)/meals/\(mealId)",
            method: .put,
            body: meal
        ) { (result: Result<Meal, Error>) in
            if case .success = result {
                NotificationCenter.default.post(
                    name: NSNotification.Name(NotificationNames.mealsUpdated),
                    object: nil
                )
            }
            completion(result)
        }
    }

    func deleteMeal(
        for userId: String,
        mealId: String,
        completion: @escaping (Result<EmptyResponse, Error>) -> Void
    ) {
        APIService.shared.request(
            endpoint: "/shared/\(userId)/meals/\(mealId)",
            method: .delete
        ) { (result: Result<EmptyResponse, Error>) in
            if case .success = result {
                NotificationCenter.default.post(
                    name: NSNotification.Name(NotificationNames.mealsUpdated),
                    object: nil
                )
            }
            completion(result)
        }
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

    func addGlucoseReading(
        for userId: String,
        reading: GlucoseReading,
        completion: @escaping (Result<GlucoseReading, Error>) -> Void
    ) {
        APIService.shared.request(
            endpoint: "/shared/\(userId)/glucose",
            method: .post,
            body: reading
        ) { (result: Result<GlucoseReading, Error>) in
            if case .success = result {
                NotificationCenter.default.post(
                    name: NSNotification.Name(NotificationNames.glucoseUpdated),
                    object: nil
                )
            }
            completion(result)
        }
    }

    func updateGlucoseReading(
        for userId: String,
        readingId: String,
        reading: GlucoseReading,
        completion: @escaping (Result<GlucoseReading, Error>) -> Void
    ) {
        APIService.shared.request(
            endpoint: "/shared/\(userId)/glucose/\(readingId)",
            method: .put,
            body: reading
        ) { (result: Result<GlucoseReading, Error>) in
            if case .success = result {
                NotificationCenter.default.post(
                    name: NSNotification.Name(NotificationNames.glucoseUpdated),
                    object: nil
                )
            }
            completion(result)
        }
    }

    func deleteGlucoseReading(
        for userId: String,
        readingId: String,
        completion: @escaping (Result<EmptyResponse, Error>) -> Void
    ) {
        APIService.shared.request(
            endpoint: "/shared/\(userId)/glucose/\(readingId)",
            method: .delete
        ) { (result: Result<EmptyResponse, Error>) in
            if case .success = result {
                NotificationCenter.default.post(
                    name: NSNotification.Name(NotificationNames.glucoseUpdated),
                    object: nil
                )
            }
            completion(result)
        }
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

    func addSymptom(
        for userId: String,
        symptom: Symptom,
        completion: @escaping (Result<Symptom, Error>) -> Void
    ) {
        APIService.shared.request(
            endpoint: "/shared/\(userId)/symptoms",
            method: .post,
            body: symptom
        ) { (result: Result<Symptom, Error>) in
            if case .success = result {
                NotificationCenter.default.post(
                    name: NSNotification.Name(NotificationNames.symptomsUpdated),
                    object: nil
                )
            }
            completion(result)
        }
    }

    func updateSymptom(
        for userId: String,
        symptomId: String,
        symptom: Symptom,
        completion: @escaping (Result<Symptom, Error>) -> Void
    ) {
        APIService.shared.request(
            endpoint: "/shared/\(userId)/symptoms/\(symptomId)",
            method: .put,
            body: symptom
        ) { (result: Result<Symptom, Error>) in
            if case .success = result {
                NotificationCenter.default.post(
                    name: NSNotification.Name(NotificationNames.symptomsUpdated),
                    object: nil
                )
            }
            completion(result)
        }
    }

    func deleteSymptom(
        for userId: String,
        symptomId: String,
        completion: @escaping (Result<EmptyResponse, Error>) -> Void
    ) {
        APIService.shared.request(
            endpoint: "/shared/\(userId)/symptoms/\(symptomId)",
            method: .delete
        ) { (result: Result<EmptyResponse, Error>) in
            if case .success = result {
                NotificationCenter.default.post(
                    name: NSNotification.Name(NotificationNames.symptomsUpdated),
                    object: nil
                )
            }
            completion(result)
        }
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

    func uploadSharedDocument(
        for userId: String,
        fileData: Data,
        fileName: String,
        documentType: String,
        docDoctorId: String? = nil,
        title: String? = nil,
        date: Date,
        completion: @escaping (Result<Document, Error>) -> Void
    ) {
        APIService.shared.uploadDocument(
            endpoint: "/shared/\(userId)/documents",
            fileData: fileData,
            fileName: fileName,
            mimeType: "application/pdf",
            documentType: documentType,
            docDoctorId: docDoctorId,
            title: title,
            date: date
        ) { (result: Result<Document, Error>) in
            if case .success = result {
                NotificationCenter.default.post(
                    name: NSNotification.Name(NotificationNames.documentsUpdated),
                    object: nil
                )
            }
            completion(result)
        }
    }

    func deleteDocument(
        for userId: String,
        documentId: String,
        completion: @escaping (Result<EmptyResponse, Error>) -> Void
    ) {
        APIService.shared.request(
            endpoint: "/shared/\(userId)/documents/\(documentId)",
            method: .delete
        ) { (result: Result<EmptyResponse, Error>) in
            if case .success = result {
                NotificationCenter.default.post(
                    name: NSNotification.Name(NotificationNames.documentsUpdated),
                    object: nil
                )
            }
            completion(result)
        }
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

    func upsertWater(
        for userId: String,
        dateRecorded: Date,
        glasses: Int,
        completion: @escaping (Result<WaterRecord, Error>) -> Void
    ) {
        struct WaterSharedRequest: Codable {
            let dateRecorded: Date
            let glasses: Int
        }

        let request = WaterSharedRequest(
            dateRecorded: dateRecorded,
            glasses: glasses
        )
        APIService.shared.request(
            endpoint: "/shared/\(userId)/water",
            method: .post,
            body: request
        ) { (result: Result<WaterRecord, Error>) in
            if case .success = result {
                NotificationCenter.default.post(
                    name: NSNotification.Name(NotificationNames.waterIntakeUpdated),
                    object: nil
                )
            }
            completion(result)
        }
    }

    func deleteWater(
        for userId: String,
        recordId: String,
        completion: @escaping (Result<EmptyResponse, Error>) -> Void
    ) {
        APIService.shared.request(
            endpoint: "/shared/\(userId)/water/\(recordId)",
            method: .delete
        ) { (result: Result<EmptyResponse, Error>) in
            if case .success = result {
                NotificationCenter.default.post(
                    name: NSNotification.Name(NotificationNames.waterIntakeUpdated),
                    object: nil
                )
            }
            completion(result)
        }
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
