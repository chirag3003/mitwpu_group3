import Foundation
import UIKit

class MealService {
    static let shared = MealService()

    private var allMeals: [Meal] = [] {
        didSet {
            NotificationCenter.default.post(
                name: NSNotification.Name(NotificationNames.mealsUpdated),
                object: nil
            )
        }
    }

    private init() {
        fetchMealsFromAPI()
    }

    func addMeal(_ meal: Meal) {
        allMeals.append(meal)

        APIService.shared.request(endpoint: "/meals", method: .post, body: meal)
        { [weak self] (result: Result<Meal, Error>) in
            switch result {
            case .success(let savedMeal):
                print("Meal saved to API: \(savedMeal.name)")
                if let index = self?.allMeals.firstIndex(where: {
                    $0.id == meal.id
                }) {
                    self?.allMeals[index].apiID = savedMeal.apiID
                    self?.allMeals[index].userId = savedMeal.userId
                }
            case .failure(let error):
                print("Error saving meal to API: \(error)")
            }
        }
    }

    func deleteMeal(_ meal: Meal) {
        allMeals.removeAll { $0.id == meal.id }

        if let apiID = meal.apiID {
            APIService.shared.request(
                endpoint: "/meals/\(apiID)",
                method: .delete
            ) { (result: Result<EmptyResponse, Error>) in
                switch result {
                case .success:
                    print("Meal deleted from API")
                case .failure(let error):
                    print("Error deleting meal from API: \(error)")
                }
            }
        }
    }

    func getMeals(forSection section: Int, on date: Date = Date()) -> [Meal] {
        let category: String
        switch section {
        case 0: category = "Breakfast"
        case 1: category = "Lunch"
        case 2: category = "Dinner"
        default: return []
        }

        let calendar = Calendar.current
        
        // Filter
        let filtered = allMeals.filter { meal in
            guard meal.type == category else {
                return false
            }
            return calendar.isDate(meal.dateRecorded, inSameDayAs: date)
        }
        return filtered
    }

    func getAllMeals() -> [Meal] {
        return allMeals
    }

    func fetchMealsFromAPI() {
        APIService.shared.request(endpoint: "/meals", method: .get) {
            [weak self] (result: Result<[Meal], Error>) in
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

    func fetchMealsUsingApiID(apiID: String) -> Meal? {
        return allMeals.first { $0.apiID == apiID }
    }

    // MARK: - Image Analysis
    func analyzeMeal(
        image: UIImage,
        completion: @escaping (Result<Meal, Error>) -> Void
    ) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(
                .failure(
                    NSError(
                        domain: "ImageConversionError",
                        code: -1,
                        userInfo: [
                            NSLocalizedDescriptionKey:
                                "Failed to convert image to data"
                        ]
                    )
                )
            )
            return
        }

        APIService.shared.upload(
            endpoint: "/meals/analyze",
            data: imageData,
            filename: "meal.jpg"
        ) { [weak self] (result: Result<AnalysisResponse, Error>) in
            guard let self = self else { return }

            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    // The API returns the saved meal in 'meal' field
                    let newMeal = response.meal
                    self.allMeals.append(newMeal)
                    completion(.success(newMeal))
                }
            case .failure(let error):
                print("Analysis failed: \(error)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }

    struct AnalysisResponse: Decodable {
        let meal: Meal
        // let analysis: AnalysisDetails // We can add this if needed, but 'meal' has everything required
    }

    struct EmptyResponse: Decodable {}
}
