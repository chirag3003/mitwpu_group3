import Foundation

class MealService {
    static let shared = MealService()
    
    private var allMeals: [Meal] = [] {
        didSet {
            NotificationCenter.default.post(name: NSNotification.Name("MealsUpdated"), object: nil)
        }
    }

    private init() {
        loadMeals()
    }

    func addMeal(_ meal: Meal) {
        CoreDataManager.shared.addMeal(meal)
        allMeals.append(meal)
    }

    func deleteMeal(_ meal: Meal) {
        CoreDataManager.shared.deleteMeal(id: meal.id)
        allMeals.removeAll { $0.id == meal.id }
    }

    func getMeals(forSection section: Int) -> [Meal] {
        let category: String
        switch section {
        case 0: category = "Breakfast"
        case 1: category = "Lunch"
        case 2: category = "Dinner"
        default: return []
        }
        return allMeals.filter { $0.type == category }
    }

    private func loadMeals() {
        let entities = CoreDataManager.shared.fetchMeals()
        
        self.allMeals = entities.map { entity in
            return Meal(
                id: entity.id ?? UUID(),
                name: entity.name ?? "Unknown",
                detail: entity.detail ?? "",
                time: entity.time ?? "",
                image: entity.image ?? "defaultImage",
                type: entity.type ?? "Breakfast",
                dateRecorded: entity.dateRecorded ?? Date()
            )
        }
    }
}
