import Foundation

final class FamilyService {
    static let shared = FamilyService()

    private var families: [Family] = [] {
        didSet {
            NotificationCenter.default.post(
                name: NSNotification.Name(NotificationNames.familiesUpdated),
                object: nil
            )
        }
    }

    private var currentFamilyId: String? {
        didSet {
            UserDefaults.standard.set(currentFamilyId, forKey: currentFamilyKey)
            NotificationCenter.default.post(
                name: NSNotification.Name(
                    NotificationNames.familySelectionUpdated
                ),
                object: nil
            )
        }
    }

    private let currentFamilyKey = "current_family_id"

    private init() {
        currentFamilyId = UserDefaults.standard.string(forKey: currentFamilyKey)
    }

    func getFamilies() -> [Family] {
        return families
    }

    func getFamily(by id: String) -> Family? {
        return families.first(where: { $0.apiID == id })
    }

    func getMemberIds(from family: Family) -> [String] {
        var ids: [String] = [family.admin.id]
        ids.append(contentsOf: family.members.map { $0.id })
        return ids
    }

    func getCurrentFamily() -> Family? {
        if let currentId = currentFamilyId,
            let family = families.first(where: { $0.apiID == currentId })
        {
            return family
        }
        return families.first
    }

    func setCurrentFamily(id: String?) {
        currentFamilyId = id
    }

    func getCurrentFamilyId() -> String? {
        if let currentId = currentFamilyId { return currentId }
        return families.first?.apiID
    }

    func getMembersForCurrentFamily() -> [FamilyMember] {
        guard let family = getCurrentFamily() else { return [] }
        return mapMembers(from: family)
    }

    func fetchFamilies(completion: ((Bool) -> Void)? = nil) {
        APIService.shared.request(endpoint: "/family", method: .get) {
            [weak self] (result: Result<[Family], Error>) in
            switch result {
            case .success(let fetched):
                self?.families = fetched
                if let currentId = self?.currentFamilyId,
                    fetched.contains(where: { $0.apiID == currentId })
                {
                    self?.currentFamilyId = currentId
                } else {
                    self?.currentFamilyId = fetched.first?.apiID
                }
                completion?(true)
            case .failure(let error):
                print("Error fetching families: \(error)")
                completion?(false)
            }
        }
    }

    func fetchFamilyMembers(
        familyId: String,
        completion: ((Bool) -> Void)? = nil
    ) {
        APIService.shared.request(
            endpoint: "/family/\(familyId)/members",
            method: .get
        ) { [weak self] (result: Result<Family, Error>) in
            switch result {
            case .success(let family):
                if let index = self?.families.firstIndex(where: {
                    $0.apiID == family.apiID
                }) {
                    self?.families[index] = family
                } else {
                    self?.families.append(family)
                }
                NotificationCenter.default.post(
                    name: NSNotification.Name(
                        NotificationNames.familyMembersUpdated
                    ),
                    object: nil
                )
                completion?(true)
            case .failure(let error):
                print("Error fetching family members: \(error)")
                completion?(false)
            }
        }
    }

    func createFamily(
        name: String,
        completion: @escaping (Result<Family, Error>) -> Void
    ) {
        struct CreateFamilyBody: Encodable {
            let name: String
        }

        APIService.shared.request(
            endpoint: "/family",
            method: .post,
            body: CreateFamilyBody(name: name)
        ) { [weak self] (result: Result<Family, Error>) in
            switch result {
            case .success(let family):
                self?.families.append(family)
                self?.currentFamilyId = family.apiID
                if let familyId = family.apiID {
                    self?.fetchFamilyMembers(
                        familyId: familyId,
                        completion: nil
                    )
                }
                completion(.success(family))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func updateFamily(
        id: String,
        name: String,
        completion: @escaping (Result<Family, Error>) -> Void
    ) {
        struct UpdateFamilyBody: Encodable {
            let name: String
        }

        APIService.shared.request(
            endpoint: "/family/\(id)",
            method: .put,
            body: UpdateFamilyBody(name: name)
        ) { [weak self] (result: Result<Family, Error>) in
            switch result {
            case .success(let updated):
                if let index = self?.families.firstIndex(where: {
                    $0.apiID == updated.apiID
                }) {
                    self?.families[index] = updated
                }
                completion(.success(updated))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func deleteFamily(id: String, completion: @escaping (Bool) -> Void) {
        APIService.shared.request(endpoint: "/family/\(id)", method: .delete) {
            [weak self] (result: Result<DeleteResponse, Error>) in
            switch result {
            case .success:
                self?.families.removeAll { $0.apiID == id }
                if self?.currentFamilyId == id {
                    self?.currentFamilyId = self?.families.first?.apiID
                }
                completion(true)
            case .failure(let error):
                print("Error deleting family: \(error)")
                completion(false)
            }
        }
    }

    func addMember(
        familyId: String,
        phoneNumber: String,
        completion: @escaping (Result<Family, Error>) -> Void
    ) {
        struct AddMemberBody: Encodable {
            let phoneNumber: String
        }

        APIService.shared.request(
            endpoint: "/family/\(familyId)/members",
            method: .post,
            body: AddMemberBody(phoneNumber: phoneNumber)
        ) { [weak self] (result: Result<Family, Error>) in
            switch result {
            case .success(let updated):
                if let index = self?.families.firstIndex(where: {
                    $0.apiID == updated.apiID
                }) {
                    self?.families[index] = updated
                }
                if let familyId = updated.apiID {
                    self?.fetchFamilyMembers(
                        familyId: familyId,
                        completion: nil
                    )
                }
                NotificationCenter.default.post(
                    name: NSNotification.Name(
                        NotificationNames.familyMembersUpdated
                    ),
                    object: nil
                )
                completion(.success(updated))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func removeMember(
        familyId: String,
        userId: String,
        completion: @escaping (Result<Family, Error>) -> Void
    ) {
        struct RemoveMemberBody: Encodable {
            let userId: String
        }

        APIService.shared.request(
            endpoint: "/family/\(familyId)/members",
            method: .delete,
            body: RemoveMemberBody(userId: userId)
        ) { [weak self] (result: Result<Family, Error>) in
            switch result {
            case .success(let updated):
                if let index = self?.families.firstIndex(where: {
                    $0.apiID == updated.apiID
                }) {
                    self?.families[index] = updated
                }
                if let familyId = updated.apiID {
                    self?.fetchFamilyMembers(
                        familyId: familyId,
                        completion: nil
                    )
                }
                NotificationCenter.default.post(
                    name: NSNotification.Name(
                        NotificationNames.familyMembersUpdated
                    ),
                    object: nil
                )
                completion(.success(updated))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func leaveFamily(familyId: String, completion: @escaping (Bool) -> Void) {
        APIService.shared.request(
            endpoint: "/family/\(familyId)/leave",
            method: .post
        ) {
            [weak self] (result: Result<LeaveFamilyResponse, Error>) in
            switch result {
            case .success:
                self?.families.removeAll { $0.apiID == familyId }
                if self?.currentFamilyId == familyId {
                    self?.currentFamilyId = self?.families.first?.apiID
                }
                completion(true)
            case .failure(let error):
                print("Error leaving family: \(error)")
                completion(false)
            }
        }
    }

    func buildFamilyMembers(from family: Family) -> [FamilyMember] {
        return mapMembers(from: family)
    }

    private func mapMembers(from family: Family) -> [FamilyMember] {
        var mapped: [FamilyMember] = []
        let currentUserId = AuthService.shared.currentUser?.id

        if family.admin.id != currentUserId {
            mapped.append(FamilyMember(user: family.admin, isAdmin: true))
        }

        mapped.append(
            contentsOf: family.members.compactMap { member in
                guard member.id != currentUserId else { return nil }
                return FamilyMember(user: member, isAdmin: false)
            }
        )
        return mapped
    }
}

struct DeleteResponse: Decodable {
    let message: String?
}

struct LeaveFamilyResponse: Decodable {
    let message: String?
    let family: Family?

    enum CodingKeys: String, CodingKey {
        case message
    }

    init(from decoder: Decoder) throws {
        if let family = try? Family(from: decoder) {
            self.family = family
            self.message = nil
            return
        }

        let container = try decoder.container(keyedBy: CodingKeys.self)
        message = try container.decodeIfPresent(String.self, forKey: .message)
        family = nil
    }
}
