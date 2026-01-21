import Foundation

class AllergyService {
    static let shared = AllergyService()
    
    private var allergies: [Allergy] = []

    private init() {
        // Initial fetch from API
        fetchAllergiesFromAPI()
    }

    // 1. Synchronous Return for UI (Returns Cached Data)
    func fetchAllergies() -> [Allergy] {
        return allergies
    }
    
    // 2. Asynchronous API Call
    func fetchAllergiesFromAPI() {
        APIService.shared.request(endpoint: "/allergies", method: .get) { [weak self] (result: Result<[Allergy], Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let fetchedAllergies):
                self.allergies = fetchedAllergies
                
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: NSNotification.Name("AllergiesUpdated"), object: nil)
                }
                
            case .failure(let error):
                print("Error fetching allergies: \(error)")
            }
        }
    }

    func addAllergy(_ allergy: Allergy) {
        // Call API
        APIService.shared.request(endpoint: "/allergies", method: .post, body: allergy) { [weak self] (result: Result<Allergy, Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let newAllergy):
                 self.allergies.append(newAllergy)
                
                 // Notify UI
                 DispatchQueue.main.async {
                     NotificationCenter.default.post(name: NSNotification.Name("AllergiesUpdated"), object: nil)
                 }
            case .failure(let error):
                print("Error adding allergy: \(error)")
            }
        }
    }
    
    // Fixing a code of delete allergy method

    func deleteAllergy(at index: Int, notify: Bool = true) {
        guard index < allergies.count else { return }
        
        let allergyToRemove = allergies[index]
        
        guard let apiID = allergyToRemove.apiID else {
            print("Warning: Deleted allergy had no apiID")
            return 
        }
        
        APIService.shared.request(endpoint: "/allergies/\(apiID)", method: .delete) { [weak self] (result: Result<EmptyResponse, Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success:
                self.allergies.removeAll(where: { $0.apiID == apiID })
                
                // Update UI
                if notify {
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: NSNotification.Name("AllergiesUpdated"), object: nil)
                    }
                }
            case .failure(let error):
                print("Error deleting allergy: \(error)")
            }
        }
    }
    
    // Helper struct for empty JSON responses
    struct EmptyResponse: Decodable {}
    
}
