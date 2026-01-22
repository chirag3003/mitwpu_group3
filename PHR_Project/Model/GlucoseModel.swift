import Foundation

enum GlucoseUnit: String, Codable {
    case mgdL = "mg/dL"
    case mmolL = "mmol/L"
}

enum MealContext: String, CaseIterable, Codable {
    case fasting = "Fasting"
    case beforeMeal = "Before Meal"
    case afterMeal = "After Meal"
    case bedtime = "Bedtime"
    case random = "Random"
}

struct GlucoseDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let value: Int
}

struct TimeOfDay: Codable {
    let hour: Int
    let minute: Int
}

struct GlucoseReading: Codable {
    let id: String?
    let userId: String?
    let value: Int
    let unit: String
    let dateRecorded: Date
    let time: TimeOfDay
    let mealContext: String?
    let notes: String?
    let createdAt: Date?
    let updatedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case userId
        case value
        case unit
        case dateRecorded
        case time
        case mealContext
        case notes
        case createdAt
        case updatedAt
    }
    
    // Custom Init for creating new readings
    init(value: Int, unit: GlucoseUnit = .mgdL, dateRecorded: Date, time: TimeOfDay, mealContext: MealContext?, notes: String?) {
        self.id = nil
        self.userId = nil
        self.value = value
        self.unit = unit.rawValue
        self.dateRecorded = dateRecorded
        self.time = time
        self.mealContext = mealContext?.rawValue
        self.notes = notes
        self.createdAt = nil
        self.updatedAt = nil
    }
}

struct GlucoseStats: Codable {
    let average: Int
    let min: Int
    let max: Int
    let count: Int
    let inRange: Int
    let belowRange: Int
    let aboveRange: Int
}
