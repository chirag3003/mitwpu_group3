import Foundation

class SymptomService {
    static let shared = SymptomService()
    
    private var symptoms: [Symptom] = [] {
        didSet {
            NotificationCenter.default.post(name: NSNotification.Name("SymptomsUpdated"), object: nil)
        }
    }

    private init() {
        loadSymptoms()
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
        // 1. Local Persistence (Core Data)
        CoreDataManager.shared.addSymptom(symptom)
        
        // 2. Optimistic Update (UI)
        symptoms.append(symptom)
        
        // 3. API Call
        APIService.shared.request(endpoint: "/symptoms", method: .post, body: symptom) { [weak self] (result: Result<Symptom, Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let savedSymptom):
                // Ideally, update the local item with the server ID, but for now we just log success
                print("Symptom synced to API: \(savedSymptom.apiID ?? "No ID")")
                
                // Optional: Update the item in the array with the one from server (which has apiID)
                if let index = self.symptoms.firstIndex(where: { $0.id == symptom.id }) {
                    DispatchQueue.main.async {
                        self.symptoms[index] = savedSymptom
                    }
                }
                
            case .failure(let error):
                print("Error adding symptom to API: \(error)")
            }
        }
    }

    func deleteSymptom(at index: Int) {
        guard index < symptoms.count else { return }
        
        let symptomToRemove = symptoms[index]
        
        // 1. Delete from Core Data (Local)
        if let id = symptomToRemove.id {
             CoreDataManager.shared.deleteSymptom(id: id)
        }
        
        // 2. Remove from Local Array (Optimistic UI)
        symptoms.remove(at: index)
        
        // 3. Delete from API
        // We need apiID to delete from server
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
    
    // Helper struct for empty JSON responses (reuse from AllergyService or define new)
    struct EmptyResponse: Decodable {}

    private func loadSymptoms() {
        let entities = CoreDataManager.shared.fetchSymptoms()
        
        self.symptoms = entities.map { entity in
            
            // Reconstruct DateComponents from the saved Int16s
            var components = DateComponents()
            components.hour = Int(entity.timeHour)
            components.minute = Int(entity.timeMinute)
            
            return Symptom(
                id: entity.id,
                symptomName: entity.symptomName ?? "Unknown",
                intensity: entity.intensity ?? "Low",
                dateRecorded: entity.dateRecorded ?? Date(),
                notes: entity.notes,
                time: components
            )
        }
    }
}
