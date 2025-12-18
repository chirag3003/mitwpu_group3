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
        
        if mealItem.count < 17 || mealDetails.count < 17 {
            print("Detected old data. Overwriting with new sample data...")
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
            // 0: Pancakes and Fruits
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

            // 1: Omelette and Toast
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

            // 2: Grilled Chicken and Vegetables
            MealDetails(
                meal: mealData[2],
                mealImage: "grilled-chicken-vegetables", // Placeholder name
                calories: 500,
                protein: 35,
                carbs: 20,
                fiber: 6,
                date: "26 Nov 2025",
                addedBy: "Sushant",
                notes: "Perfect balanced lunch."
            ),

            // 3: Beef Stir Fry
            MealDetails(
                meal: mealData[3],
                mealImage: "beef-stir-fry", // Placeholder name
                calories: 650,
                protein: 40,
                carbs: 45,
                fiber: 7,
                date: "26 Nov 2025",
                addedBy: "Sushant",
                notes: "High-calorie meal good for dinner."
            ),
            
            // 4: Spaghetti with Marinara Sauce
            MealDetails(
                meal: mealData[4],
                mealImage: "spaghetti-marinara", // Placeholder name
                calories: 480,
                protein: 12,
                carbs: 70,
                fiber: 6,
                date: "27 Nov 2025",
                addedBy: "Sushant",
                notes: "Classic comfort food."
            ),

            // 5: Tacos al Pastor
            MealDetails(
                meal: mealData[5],
                mealImage: "tacos-pastor", // Placeholder name
                calories: 550,
                protein: 22,
                carbs: 45,
                fiber: 4,
                date: "27 Nov 2025",
                addedBy: "Sushant",
                notes: "Dinner out with friends."
            ),

            // 6: Vegetable Curry
            MealDetails(
                meal: mealData[6],
                mealImage: "veg-curry", // Placeholder name
                calories: 380,
                protein: 10,
                carbs: 50,
                fiber: 9,
                date: "27 Nov 2025",
                addedBy: "Sushant",
                notes: "Spicy and rich in vegetables."
            ),

            // 7: Lentil Soup
            MealDetails(
                meal: mealData[7],
                mealImage: "lentil-soup", // Placeholder name
                calories: 320,
                protein: 18,
                carbs: 40,
                fiber: 12,
                date: "28 Nov 2025",
                addedBy: "Sushant",
                notes: "Great source of fiber and iron."
            ),

            // 8: Pancakes and Fruits (Repeat)
            MealDetails(
                meal: mealData[8],
                mealImage: "banana-pancakes-4",
                calories: 360,
                protein: 8,
                carbs: 56,
                fiber: 5,
                date: "28 Nov 2025",
                addedBy: "Sushant",
                notes: "Added extra strawberries today."
            ),

            // 9: Omelette and Toast (Repeat)
            MealDetails(
                meal: mealData[9],
                mealImage: "egg-white-omelet-09",
                calories: 410,
                protein: 20,
                carbs: 28,
                fiber: 4,
                date: "29 Nov 2025",
                addedBy: "Sushant",
                notes: "Quick post-workout meal."
            ),

            // 10: Grilled Chicken and Vegetables (Repeat)
            MealDetails(
                meal: mealData[10],
                mealImage: "grilled-chicken", // Placeholder name
                calories: 510,
                protein: 36,
                carbs: 18,
                fiber: 6,
                date: "29 Nov 2025",
                addedBy: "Sushant",
                notes: "Meal prep lunch."
            ),

            // 11: Beef Stir Fry (Repeat)
            MealDetails(
                meal: mealData[11],
                mealImage: "beef-stir-fry", // Placeholder name
                calories: 640,
                protein: 39,
                carbs: 46,
                fiber: 7,
                date: "29 Nov 2025",
                addedBy: "Sushant",
                notes: "Leftovers from the other night."
            ),

            // 12: Spaghetti with Marinara Sauce (Repeat)
            MealDetails(
                meal: mealData[12],
                mealImage: "spaghetti-marinara", // Placeholder name
                calories: 490,
                protein: 13,
                carbs: 71,
                fiber: 6,
                date: "30 Nov 2025",
                addedBy: "Sushant",
                notes: "Quick dinner."
            ),

            // 13: Tacos al Pastor (Repeat)
            MealDetails(
                meal: mealData[13],
                mealImage: "tacos-pastor", // Placeholder name
                calories: 560,
                protein: 23,
                carbs: 44,
                fiber: 5,
                date: "30 Nov 2025",
                addedBy: "Sushant",
                notes: "Tacos again!"
            ),

            // 14: Vegetable Curry (Repeat)
            MealDetails(
                meal: mealData[14],
                mealImage: "veg-curry", // Placeholder name
                calories: 390,
                protein: 11,
                carbs: 48,
                fiber: 9,
                date: "01 Dec 2025",
                addedBy: "Sushant",
                notes: "Added chickpeas for extra protein."
            ),

            // 15: Lentil Soup (Repeat)
            MealDetails(
                meal: mealData[15],
                mealImage: "lentil-soup", // Placeholder name
                calories: 325,
                protein: 18,
                carbs: 41,
                fiber: 12,
                date: "01 Dec 2025",
                addedBy: "Sushant",
                notes: "Warm soup for a cold day."
            ),

            // 16: Chocolate Lava Cake
            MealDetails(
                meal: mealData[16],
                mealImage: "lava-cake", // Placeholder name
                calories: 450,
                protein: 5,
                carbs: 55,
                fiber: 2,
                date: "01 Dec 2025",
                addedBy: "Sushant",
                notes: "A well-deserved cheat meal ."
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


