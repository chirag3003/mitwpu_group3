import Foundation

// MARK: - Auth Models

struct AuthRequest: Codable {
    let phoneNumber: String
}

struct AuthUser: Codable {
    let id: String
    let phoneNumber: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case phoneNumber
    }
}

struct AuthResponse: Codable {
    let user: AuthUser
    let token: String
}
