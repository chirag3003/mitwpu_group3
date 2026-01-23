import Foundation


struct ProfileModel: Codable {
    var apiID: String?  // MongoDB _id
    var userId: String? // MongoDB userId
    var firstName: String
    var lastName: String
    var dob: Foundation.Date
    var sex: String
    var diabetesType: String
    var bloodType: String
    var height: Int
    var weight: Int
    
    enum CodingKeys: String, CodingKey {
        case apiID = "_id"
        case userId
        case firstName
        case lastName
        case dob
        case sex
        case diabetesType
        case bloodType
        case height
        case weight
    }
}
