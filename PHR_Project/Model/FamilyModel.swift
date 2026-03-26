import Foundation

struct Family: Codable {
    var apiID: String?
    var name: String
    var admin: FamilyUser
    var members: [FamilyUser]

    enum CodingKeys: String, CodingKey {
        case apiID = "_id"
        case name
        case admin
        case members
    }

    init(apiID: String? = nil, name: String, admin: FamilyUser, members: [FamilyUser]) {
        self.apiID = apiID
        self.name = name
        self.admin = admin
        self.members = members
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        apiID = try container.decodeIfPresent(String.self, forKey: .apiID)
        name = try container.decode(String.self, forKey: .name)
        admin = try Family.decodeUser(from: container, forKey: .admin)
        members = try Family.decodeMembers(from: container, forKey: .members)
    }

    private static func decodeUser(
        from container: KeyedDecodingContainer<CodingKeys>,
        forKey key: CodingKeys
    ) throws -> FamilyUser {
        if let user = try? container.decode(FamilyUser.self, forKey: key) {
            return user
        }
        let id = try container.decode(String.self, forKey: key)
        return FamilyUser(id: id, phoneNumber: nil, name: nil, profileImage: nil)
    }

    private static func decodeMembers(
        from container: KeyedDecodingContainer<CodingKeys>,
        forKey key: CodingKeys
    ) throws -> [FamilyUser] {
        if let users = try? container.decode([FamilyUser].self, forKey: key) {
            return users
        }
        let ids = try container.decode([String].self, forKey: key)
        return ids.map {
            FamilyUser(id: $0, phoneNumber: nil, name: nil, profileImage: nil)
        }
    }
}

struct FamilyUser: Codable {
    var id: String
    var phoneNumber: String?
    var name: String?
    var profileImage: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case phoneNumber
        case name
        case profileImage
    }
}

struct FamilyPermission: Codable {
    var apiID: String?
    var userId: String
    var permissionTo: String
    var write: Bool
    var permissions: FamilyPermissionFlags

    enum CodingKeys: String, CodingKey {
        case apiID = "_id"
        case userId
        case permissionTo
        case write
        case permissions
    }
}

struct FamilyPermissionFlags: Codable {
    var documents: Bool
    var symptoms: Bool
    var meals: Bool
    var glucose: Bool
    var allergies: Bool
    var water: Bool
    var steps: Bool

    static let allDisabled = FamilyPermissionFlags(
        documents: false,
        symptoms: false,
        meals: false,
        glucose: false,
        allergies: false,
        water: false,
        steps: false
    )

    static let allEnabled = FamilyPermissionFlags(
        documents: true,
        symptoms: true,
        meals: true,
        glucose: true,
        allergies: true,
        water: true,
        steps: true
    )
}

struct FamilyMember {
    let userId: String
    let name: String
    let imageName: String
    let phoneNumber: String?
    let isAdmin: Bool
}

extension FamilyMember {
    init(user: FamilyUser, isAdmin: Bool) {
        self.userId = user.id
        self.name = user.name ?? "Family Member"
        self.imageName = user.profileImage ?? ""
        self.phoneNumber = user.phoneNumber
        self.isAdmin = isAdmin
    }
}
