import Foundation

class SymptomService {
    static let shared = SymptomService()
    private let storageKey = "saved_symptoms_list"

    private var symptoms: [Symptom] = [] {
        didSet {
            save()
            NotificationCenter.default.post(name: NSNotification.Name("SymptomsUpdated"), object: nil)

        }
    }

    private init() {
        loadSymptoms()
    }

    func getSymptoms() -> [Symptom] {
        return symptoms
    }

    func addSymptom(_ symptom: Symptom) {
        symptoms.append(symptom)
    }

    private func save() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(symptoms)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            print("Failed to save symptoms: \(error)")
        }
    }

    private func loadSymptoms() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else {
            return
        }

        do {
            let decoder = JSONDecoder()
            symptoms = try decoder.decode([Symptom].self, from: data)
        } catch {
            print("Failed to load symptoms: \(error)")
        }
    }
    
     func deleteSymptom(at index: Int) {
        if index < symptoms.count {
            symptoms.remove(at: index)
        }
    }
    
}
