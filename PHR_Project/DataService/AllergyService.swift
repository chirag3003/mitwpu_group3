import CoreData
import Foundation

class AllergyService {
    static let shared = AllergyService()
    private let storageKey = "saved_allergies_list"

    private var allergies: [Allergy] = []{
        didSet{
            save()
        }
    }
    private init() {
        loadAllergies()
    }

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

    // MARK: - Persistence Logic

    private func save() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(allergies)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            print("Failed to save allergies: \(error)")
        }
    }

    private func loadAllergies() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else {
            return
        }

        do {
            let decoder = JSONDecoder()
            allergies = try decoder.decode([Allergy].self, from: data)
        } catch {
            print("Failed to load allergies: \(error)")
        }
    }
}
