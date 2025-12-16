import Foundation

class MealService {
    static let shared = MealService()
    private let storageKey = "saved_meals" // Unique key for UserDefaults
    
    private var allMeals: [Meal] = [] {
        didSet {
            save()
            NotificationCenter.default.post(name: NSNotification.Name("MealsUpdated"), object: nil)
        }
    }

    private init() {
        loadMeals()
    }

    func addMeal(_ meal: Meal) {
        allMeals.append(meal)
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

    // MARK: - Saving & Loading
    private func save() {
        if let data = try? JSONEncoder().encode(allMeals) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    private func loadMeals() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let savedMeals = try? JSONDecoder().decode([Meal].self, from: data) {
            allMeals = savedMeals
        }
    }
    
    func deleteMeal(_ meal: Meal){
        allMeals.removeAll { $0.id == meal.id }
    }
}
