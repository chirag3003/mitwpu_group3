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
    }

    func getSymptoms() -> [Symptom] {
        return symptoms
    }

    func addSymptom(_ symptom: Symptom) {
        CoreDataManager.shared.addSymptom(symptom)
        symptoms.append(symptom)
    }

    func deleteSymptom(at index: Int) {
        guard index < symptoms.count else { return }
        
        let symptomToRemove = symptoms[index]
        if let id = symptomToRemove.id {
             CoreDataManager.shared.deleteSymptom(id: id)
        }
        
        symptoms.remove(at: index)
    }

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
