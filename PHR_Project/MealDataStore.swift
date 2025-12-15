import Foundation

class MealDataStore {
    
    static let shared = MealDataStore()
    
    private let mealItemsKey = StorageKeys.mealItems
    private let mealDetailsKey = StorageKeys.mealDetails
    private let daysKey = StorageKeys.calendarDays
    
    
    
    private var mealItem: [MealItem] = [] {
        didSet {
            saveMealItems()
        }
    }
    
    private var mealDetails: [MealDetails] = [] {
        didSet {
            saveMealDetails()
        }
    }
    
    private var days: [CalendarDay] = []
    
    
    func getMealItem() -> [MealItem] {
        return mealItem
    }
    
    func getMealDetails() -> [MealDetails] {
        return mealDetails
    }
    
    func getDays() -> [CalendarDay] {
        return days
    }
    
    private init() {
        loadMealItems()
        loadMealDetails()
        //loadDays()
        
        if mealItem.isEmpty {
            loadSampleData()
        }
        
        self.days = generateNext30Days()
        print(days)
        
        
    }
    
    func loadSampleData() {
        let mealData: [MealItem] = [
            MealItem(id: UUID(), name: "Pancakes and Fruits"),
            MealItem(id: UUID(), name: "Omelette and Toast"),
            MealItem(id: UUID(), name: "Grilled Chicken and Vegetables"),
            MealItem(id: UUID(), name: "Beef Stir Fry"),
            MealItem(id: UUID(), name: "Spaghetti with Marinara Sauce"),
            MealItem(id: UUID(), name: "Tacos al Pastor"),
            MealItem(id: UUID(), name: "Vegetable Curry"),
            MealItem(id: UUID(), name: "Lentil Soup"),
            MealItem(id: UUID(), name: "Pancakes and Fruits"),
            MealItem(id: UUID(), name: "Omelette and Toast"),
            MealItem(id: UUID(), name: "Grilled Chicken and Vegetables"),
            MealItem(id: UUID(), name: "Beef Stir Fry"),
            MealItem(id: UUID(), name: "Spaghetti with Marinara Sauce"),
            MealItem(id: UUID(), name: "Tacos al Pastor"),
            MealItem(id: UUID(), name: "Vegetable Curry"),
            MealItem(id: UUID(), name: "Lentil Soup"),
            MealItem(id: UUID(), name: "Chocolate Lava Cake")
        ]
        
        let mealDetailsData: [MealDetails] = [
            MealDetails(
                meal: mealData[0],
                mealImage: "banana-pancakes-4",
                calories: 350,
                protein: 8,
                carbs: 55,
                fiber: 5,
                date: "26 Nov 2025",
                addedBy: "Sushant",
                notes: "A light and sweet breakfast option."
            ),
            
            MealDetails(
                meal: mealData[1],
                mealImage: "egg-white-omelet-09",
                calories: 420,
                protein: 20,
                carbs: 30,
                fiber: 4,
                date: "26 Nov 2025",
                addedBy: "Sushant",
                notes: "High-protein breakfast with toast."
            ),
            
            MealDetails(
                meal: mealData[2],
                mealImage: "",
                calories: 500,
                protein: 35,
                carbs: 20,
                fiber: 6,
                date: "26 Nov 2025",
                addedBy: "Sushant",
                notes: "Perfect balanced lunch."
            ),
            
            MealDetails(
                meal: mealData[3],
                mealImage: "",
                calories: 650,
                protein: 40,
                carbs: 45,
                fiber: 7,
                date: "26 Nov 2025",
                addedBy: "Sushant",
                notes: "High-calorie meal good for dinner."
            )
        ]
    

        self.mealItem = mealData
        self.mealDetails = mealDetailsData
        //self.days = dayData
    }
    
    private func saveMealItems() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(mealItem)
            UserDefaults.standard.set(data, forKey: mealItemsKey)
        } catch {
            print("Failed to save meal items: \(error)")
        }
    }
    
    private func saveMealDetails() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(mealDetails)
            UserDefaults.standard.set(data, forKey: mealDetailsKey)
        } catch {
            print("Failed to save meal details: \(error)")
        }
    }
    
    private func saveDays() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(days)
            UserDefaults.standard.set(data, forKey: daysKey)
        } catch {
            print("Failed to save calendar days: \(error)")
        }
    }
    
    private func loadMealItems() {
        guard let data = UserDefaults.standard.data(forKey: mealItemsKey) else {
            return
        }
        
        do {
            let decoder = JSONDecoder()
            mealItem = try decoder.decode([MealItem].self, from: data)
        } catch {
            print("Failed to load meal items: \(error)")
        }
    }
    
    private func loadMealDetails() {
        guard let data = UserDefaults.standard.data(forKey: mealDetailsKey) else {
            return
        }
        
        do {
            let decoder = JSONDecoder()
            mealDetails = try decoder.decode([MealDetails].self, from: data)
        } catch {
            print("Failed to load meal details: \(error)")
        }
    }
    
    private func loadDays() {
        guard let data = UserDefaults.standard.data(forKey: daysKey) else {
            return
        }
        
        do {
            let decoder = JSONDecoder()
            days = try decoder.decode([CalendarDay].self, from: data)
        } catch {
            print("Failed to load calendar days: \(error)")
        }
    }
    
    private func generateNext30Days() -> [CalendarDay] {
        var generatedDays: [CalendarDay] = []
        let calendar = Calendar.current
        let today = Date()
        let dateFormatter = DateFormatter()
        
        for i in -15...15 {
            if let date = calendar.date(byAdding: .day, value: i, to: today) {
                
                dateFormatter.dateFormat = "EEEEE"
                let dayString = dateFormatter.string(from: date)
                
                dateFormatter.dateFormat = "d"
                let numberString = dateFormatter.string(from: date)
                
                let dayObject = CalendarDay(day: dayString, number: numberString)
                generatedDays.append(dayObject)
            }
        }
        return generatedDays
    }
}


