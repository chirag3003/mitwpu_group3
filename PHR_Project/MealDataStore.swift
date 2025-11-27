//
//  MealDataStore.swift
//  PHR_Project
//
//  Created by Sushant Pulipati on 26/11/25.
//
import Foundation

class MealDataStore {
    
    static let shared = MealDataStore()
    
    private var mealItem: [MealItem] = []
    private var mealDetails: [MealDetails] = []
    
    func getMealItem() -> [MealItem] {
        return mealItem
    }
    
    func getMealDetails() -> [MealDetails] {
        return mealDetails
    }
    
    private init() {
        loadSampleData()
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
    }
    
}
