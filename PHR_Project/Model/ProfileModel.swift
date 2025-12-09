import Foundation


struct ProfileModel: Codable {
    var firstName: String
    var lastName: String
    var dob: Foundation.Date
    var sex: String
    var diabetesType: String
    var bloodType: String
    var height: Int
    var weight: Int
}
