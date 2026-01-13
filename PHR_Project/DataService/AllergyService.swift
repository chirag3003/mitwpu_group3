import Foundation

class AllergyService {
    static let shared = AllergyService()
    
    private var allergies: [Allergy] = [] {
        didSet {
            // Notification if needed
        }
    }

    private init() {
        loadAllergies()
    }

    func fetchAllergies() -> [Allergy] {
        return allergies
    }

    func addAllergy(_ allergy: Allergy) {
        CoreDataManager.shared.addAllergy(allergy)
        allergies.append(allergy)
    }

    func removeAllergy(_ allergy: Allergy) {
        guard let id = allergy.id else { return }
        
        CoreDataManager.shared.deleteAllergy(id: id)
        allergies.removeAll { $0.id == id }
    }

    private func loadAllergies() {
        let entities = CoreDataManager.shared.fetchAllergies()
        
        self.allergies = entities.map { entity in
            return Allergy(
                id: entity.id,
                name: entity.name ?? "Unknown",
                severity: entity.severity ?? "Mild",
                notes: entity.notes
            )
        }
    }
    
    // Fixing a code of delete allergy method

    func deleteAllergy(at index: Int) {
        // 1. Check if index is valid
        guard index < allergies.count else { return }
        
        // 2. Get the item to remove
        let allergyToRemove = allergies[index]
        
        // 3. Remove from Core Data using its ID
        if let id = allergyToRemove.id {
             CoreDataManager.shared.deleteAllergy(id: id)
        }
        
        // 4. Remove from local array
        allergies.remove(at: index)
    }
    
}
