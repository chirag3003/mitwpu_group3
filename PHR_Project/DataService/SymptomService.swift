import Foundation

class SymptomService {
    static let shared = SymptomService()

    private var symptoms: [Symptom] = [] {
        didSet {
            NotificationCenter.default.post(
                name: NSNotification.Name(NotificationNames.symptomsUpdated),
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
                    self.symptoms.append(savedSymptom)
                }
                completion(.success(savedSymptom))
            case .failure(let error):
                print("Error adding symptom to API: \(error)")
                completion(.failure(error))
            }
        }
    }

    func deleteSymptom(at index: Int) {
        guard index < symptoms.count else { return }

        let symptomToRemove = symptoms[index]
        guard let apiID = symptomToRemove.apiID else {
            return
        }

        APIService.shared.request(
            endpoint: "/symptoms/\(apiID)",
            method: .delete
        ) { (result: Result<EmptyResponse, Error>) in
            if case .failure(let error) = result {
                print("Error deleting symptom from API: \(error)")
            } else {
                self.symptoms.remove(at: index)
            }
        }
    }

    // Helper struct for empty JSON responses
    struct EmptyResponse: Decodable {}

}
