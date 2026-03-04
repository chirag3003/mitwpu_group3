import Foundation

struct WaterRecord: Codable {
    let id: String?
    let userId: String?
    let dateRecorded: Date
    let glasses: Int
    let createdAt: Date?
    let updatedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case userId
        case dateRecorded
        case glasses
        case createdAt
        case updatedAt
    }
}

struct WaterUpsertRequest: Codable {
    let dateRecorded: String
    let glasses: Int
}

struct WaterUpdateRequest: Codable {
    let dateRecorded: String?
    let glasses: Int?
}
