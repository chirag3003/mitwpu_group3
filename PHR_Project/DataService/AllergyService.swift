import Foundation

class AllergyService {
    static let shared = AllergyService()
    
    private var allergies: [Allergy] = [] {
        didSet {
            // Notification if needed
        }
    }

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
                    // Notify UI to reload
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
                 print("Allergy added to API: \(newAllergy.apiID ?? "No ID")")
                 
                 // Add to local storage only on success
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
        // 1. Check if index is valid
        guard index < allergies.count else { return }
        
        // 2. Get the item to remove
        let allergyToRemove = allergies[index]
        
        // 3. Remove from local array (Optimistic UI)
        allergies.remove(at: index)
        
        if notify {
            NotificationCenter.default.post(name: NSNotification.Name("AllergiesUpdated"), object: nil)
        }
        
        // 4. Call API to delete
        // prefer apiID (Server ID)
        guard let apiID = allergyToRemove.apiID else {
            print("Warning: Deleted allergy had no apiID")
            return 
        }
        
        APIService.shared.request(endpoint: "/allergies/\(apiID)", method: .delete) { (result: Result<EmptyResponse, Error>) in
             // Handle error if needed
        }
    }
    
    // Helper struct for empty JSON responses
    struct EmptyResponse: Decodable {}
    
}
