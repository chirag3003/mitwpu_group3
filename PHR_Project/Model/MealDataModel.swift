//
//  MealDataModel.swift
//  PHR_Project
//
//  Created by Sushant Pulipati on 25/11/25.
//
import Foundation

struct MealItem {
    let id: UUID
    let name: String
}

struct MealDetails {
    let meal: MealItem
    let mealImage: String
    let calories: Int
    let protein: Int
    let carbs: Int
    let fiber: Int
    let date: String
    let addedBy: String
    let notes: String
}

// Renamed from `Date` to avoid shadowing Foundation.Date
struct CalendarDay {
    let day: String
    let number: String
}

