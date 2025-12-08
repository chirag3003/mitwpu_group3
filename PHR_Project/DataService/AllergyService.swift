import Foundation
import CoreData


class AllergyService {
    static let shared = AllergyService()
    
    private var allergies: [Allergy] = []
    private init() {}
    
    func fetchAllergies() -> [Allergy] {
        return allergies
    }
    
    func addAllergy(_ allergy: Allergy) {
        allergies.append(allergy)
    }
    
    func removeAllergy(_ allergy: Allergy) {
        allergies.removeAll { $0.id == allergy.id }
    }
    
    func getAllergyByID(_ id: UUID) -> Allergy? {
        return allergies.first(where: { $0.id == id })
    }
}
