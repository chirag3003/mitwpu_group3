import Foundation

class SymptomService {
    static let shared = SymptomService()
    
    private var symptoms: [Symptom] = [] {
        didSet {
            NotificationCenter.default.post(name: NSNotification.Name("SymptomsUpdated"), object: nil)
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
        APIService.shared.request(endpoint: "/symptoms", method: .get) { [weak self] (result: Result<[Symptom], Error>) in
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

    func addSymptom(_ symptom: Symptom) {
        // 1. Optimistic Update (UI)
        symptoms.append(symptom)
        
        // 2. API Call
        APIService.shared.request(endpoint: "/symptoms", method: .post, body: symptom) { [weak self] (result: Result<Symptom, Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let savedSymptom):
                // Sync server ID
                print("Symptom synced to API: \(savedSymptom.apiID ?? "No ID")")
                
                if let index = self.symptoms.firstIndex(where: { $0.id == symptom.id }) {
                    DispatchQueue.main.async {
                        self.symptoms[index] = savedSymptom
                    }
                }
                
            case .failure(let error):
                print("Error adding symptom to API: \(error)")
                // Since there is no rollback here, data might be out of sync on error. 
                // Consider implementing rollback in future.
            }
        }
    }

    func deleteSymptom(at index: Int) {
        guard index < symptoms.count else { return }
        
        let symptomToRemove = symptoms[index]
        
        // 1. Remove from Local Array (Optimistic UI)
        symptoms.remove(at: index)
        
        // 2. Delete from API
        guard let apiID = symptomToRemove.apiID else {
            print("Warning: Symptom has no apiID, cannot delete from server (local only?)")
            return
        }
        
        APIService.shared.request(endpoint: "/symptoms/\(apiID)", method: .delete) { (result: Result<EmptyResponse, Error>) in
            if case .failure(let error) = result {
                print("Error deleting symptom from API: \(error)")
            }
        }
    }
    
    // Helper struct for empty JSON responses
    struct EmptyResponse: Decodable {}
    
}
