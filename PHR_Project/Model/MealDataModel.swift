//
//  MealDataModel.swift
//  PHR_Project
//
//  Created by Sushant Pulipati on 25/11/25.
//
import Foundation

struct MealItem: Codable {
    let id: UUID
    let name: String
}

struct MealDetails: Codable {
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

struct CalendarDay: Codable {
    let day: String
    let number: String
}

