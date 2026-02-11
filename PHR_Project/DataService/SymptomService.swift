import Foundation

class SymptomService {
    static let shared = SymptomService()

    private var symptoms: [Symptom] = [] {
        didSet {
            NotificationCenter.default.post(
                name: NSNotification.Name("SymptomsUpdated"),
                object: nil
            )
        }
    }

    private init() {
        fetchSymptomsFromAPI()
    }

    func getSymptoms() -> [Symptom] {
        return symptoms
    }

    // MARK: - API Integration

    func fetchSymptomsFromAPI() {
        APIService.shared.request(endpoint: "/symptoms", method: .get) {
            [weak self] (result: Result<[Symptom], Error>) in
            guard let self = self else { return }

            switch result {
            case .success(let fetchedSymptoms):
                DispatchQueue.main.async {
                    self.symptoms = fetchedSymptoms
                }
            case .failure(let error):
                print("Error fetching symptoms: \(error)")
            }
        }
    }

    func addSymptom(
        _ symptom: Symptom,
        completion: @escaping (Result<Symptom, Error>) -> Void
    ) {
        APIService.shared.request(
            endpoint: "/symptoms",
            method: .post,
            body: symptom
        ) { [weak self] (result: Result<Symptom, Error>) in
            guard let self = self else { return }

            switch result {
            case .success(let savedSymptom):
                DispatchQueue.main.async {
                    // Append locally immediately
                    self.symptoms.append(savedSymptom)
                }
                completion(.success(savedSymptom))
            case .failure(let error):
                print("Error adding symptom: \(error)")
                completion(.failure(error))
            }
        }
    }

    // MARK: - ROBUST UPDATE FUNCTION
    func updateSymptom(
        _ symptom: Symptom,
        completion: @escaping (Result<Symptom, Error>) -> Void
    ) {
        // 1. Validate ID
        guard let apiID = symptom.apiID else {
            print("Error: Cannot update symptom without apiID")
            completion(.failure(NSError(domain: "UpdateError", code: 404, userInfo: [NSLocalizedDescriptionKey: "Missing apiID"])))
            return
        }

        // 2. Perform API Request
        APIService.shared.request(
            endpoint: "/symptoms/\(apiID)",
            method: .put,
            body: symptom
        ) { [weak self] (result: Result<Symptom, Error>) in
            guard let self = self else { return }

            DispatchQueue.main.async {
                switch result {
                case .success(let updatedSymptomFromAPI):
                    // 3. FORCE UPDATE LOCAL ARRAY
                    // We look for the index using the apiID we sent.
                    if let index = self.symptoms.firstIndex(where: { $0.apiID == apiID }) {
                        // We update the local model with the API response
                        self.symptoms[index] = updatedSymptomFromAPI
                        print("✅ Local symptom updated successfully at index \(index)")
                    } else {
                        // Fallback: If not found (rare), append it or re-fetch
                        print("⚠️ Symptom updated in API but not found locally. Refetching...")
                        self.fetchSymptomsFromAPI()
                    }
                    completion(.success(updatedSymptomFromAPI))

                case .failure(let error):
                    print("❌ Error updating symptom API: \(error)")
                    // Optional: Optimistic update fallback?
                    // For now, let's trust the API failure and strictly return error.
                    completion(.failure(error))
                }
            }
        }
    }

    func deleteSymptom(at index: Int) {
        guard index < symptoms.count else { return }
        let symptomToRemove = symptoms[index]
        guard let apiID = symptomToRemove.apiID else { return }

        // Optimistically remove from UI immediately for better UX
        DispatchQueue.main.async {
             self.symptoms.remove(at: index)
        }

        APIService.shared.request(
            endpoint: "/symptoms/\(apiID)",
            method: .delete
        ) { (result: Result<EmptyResponse, Error>) in
            if case .failure(let error) = result {
                print("Error deleting symptom: \(error)")
                // Optionally re-fetch if delete failed
                self.fetchSymptomsFromAPI()
            }
        }
    }

    struct EmptyResponse: Decodable {}
}
