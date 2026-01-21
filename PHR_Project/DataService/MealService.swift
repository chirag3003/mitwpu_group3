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
        fetchMealsFromAPI()
    }

    func addMeal(_ meal: Meal) {
        // Optimistic Update
        CoreDataManager.shared.addMeal(meal)
        allMeals.append(meal)
        
        // API Call
        APIService.shared.request(endpoint: "/meals", method: .post, body: meal) { [weak self] (result: Result<Meal, Error>) in
            switch result {
            case .success(let savedMeal):
                print("Meal saved to API: \(savedMeal.name)")
                // Update local ID if needed
                if let index = self?.allMeals.firstIndex(where: { $0.id == meal.id }) {
                    self?.allMeals[index].apiID = savedMeal.apiID
                    self?.allMeals[index].userId = savedMeal.userId
                }
            case .failure(let error):
                print("Error saving meal to API: \(error)")
            }
        }
    }

    func deleteMeal(_ meal: Meal) {
        // Optimistic Delete
        CoreDataManager.shared.deleteMeal(id: meal.id)
        allMeals.removeAll { $0.id == meal.id }
        
        // API Call
        if let apiID = meal.apiID {
            APIService.shared.request(endpoint: "/meals/\(apiID)", method: .delete) { (result: Result<EmptyResponse, Error>) in
                switch result {
                case .success:
                    print("Meal deleted from API")
                case .failure(let error):
                    print("Error deleting meal from API: \(error)")
                }
            }
        }
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
                dateRecorded: entity.dateRecorded ?? Date(),
                calories: 0, // Default for CD
                protein: 0,
                carbs: 0,
                fiber: 0,
                addedBy: "Self",
                notes: nil
            )
        }
    }
    
    func fetchMealsFromAPI() {
        APIService.shared.request(endpoint: "/meals", method: .get) { [weak self] (result: Result<[Meal], Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let meals):
                DispatchQueue.main.async {
                    // Update in-memory
                    self.allMeals = meals
                }
            case .failure(let error):
                print("Error fetching meals: \(error)")
            }
        }
    }
    
    struct EmptyResponse: Decodable {}
}
