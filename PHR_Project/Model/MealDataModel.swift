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

struct Meal: Codable {
    var apiID: String?
    var userId: String?
    var id: UUID = UUID() // Local unique ID
    let name: String
    let detail: String?
    let time: String
    let image: String?
    let type: String      // "Breakfast", "Lunch", "Dinner", "Snack"
    let dateRecorded: Date
    
    // Nutritional Info
    let calories: Int
    let protein: Int
    let carbs: Int
    let fiber: Int
    
    // Extra
    let addedBy: String
    let notes: String?
    
    enum CodingKeys: String, CodingKey {
        case apiID = "_id"
        case userId
        case name
        case detail
        case time
        case image = "mealImage" // API uses 'mealImage'
        case type
        case dateRecorded
        case calories
        case protein
        case carbs
        case fiber
        case addedBy
        case notes
    }
    
    // Custom init for manual creation (optional, helps dealing with non-optional let properties)
    init(id: UUID = UUID(), apiID: String? = nil, userId: String? = nil, name: String, detail: String?, time: String, image: String?, type: String, dateRecorded: Date, calories: Int, protein: Int, carbs: Int, fiber: Int, addedBy: String, notes: String?) {
        self.id = id
        self.apiID = apiID
        self.userId = userId
        self.name = name
        self.detail = detail
        self.time = time
        self.image = image
        self.type = type
        self.dateRecorded = dateRecorded
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fiber = fiber
        self.addedBy = addedBy
        self.notes = notes
    }
    
    // Decodable init
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        apiID = try container.decodeIfPresent(String.self, forKey: .apiID)
        userId = try container.decodeIfPresent(String.self, forKey: .userId)
        name = try container.decode(String.self, forKey: .name)
        detail = try container.decodeIfPresent(String.self, forKey: .detail)
        time = try container.decode(String.self, forKey: .time)
        image = try container.decodeIfPresent(String.self, forKey: .image)
        type = try container.decode(String.self, forKey: .type)
        dateRecorded = try container.decode(Date.self, forKey: .dateRecorded)
        calories = Int(try container.decode(Double.self, forKey: .calories))
        protein = Int(try container.decode(Double.self, forKey: .protein))
        carbs = Int(try container.decode(Double.self, forKey: .carbs))
        fiber = Int(try container.decode(Double.self, forKey: .fiber))
        
        addedBy = try container.decode(String.self, forKey: .addedBy)
        notes = try container.decodeIfPresent(String.self, forKey: .notes)
        
        // Ensure id is set locally
        id = UUID() 
    }
    
    // Encodable
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(apiID, forKey: .apiID)
        try container.encodeIfPresent(userId, forKey: .userId)
        try container.encode(name, forKey: .name)
        try container.encode(detail, forKey: .detail)
        try container.encode(time, forKey: .time)
        try container.encode(image, forKey: .image)
        try container.encode(type, forKey: .type)
        try container.encode(dateRecorded, forKey: .dateRecorded)
        try container.encode(calories, forKey: .calories)
        try container.encode(protein, forKey: .protein)
        try container.encode(carbs, forKey: .carbs)
        try container.encode(fiber, forKey: .fiber)
        try container.encode(addedBy, forKey: .addedBy)
        try container.encode(notes, forKey: .notes)
    }
}
