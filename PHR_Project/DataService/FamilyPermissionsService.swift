import Foundation

final class FamilyPermissionsService {
    static let shared = FamilyPermissionsService()

    private init() {}

    func getPermissions(
        for userId: String,
        completion: @escaping (FamilyPermission?) -> Void
    ) {
        APIService.shared.request(
            endpoint: "/family/permissions?permissionTo=\(userId)",
            method: .get
        ) { (result: Result<FamilyPermission, Error>) in
            switch result {
            case .success(let permission):
                completion(permission)
            case .failure(let error):
                print("Error fetching permissions: \(error)")
                completion(nil)
            }
        }
    }

    func getPermissionsFrom(
        userId: String,
        completion: @escaping (FamilyPermission?) -> Void
    ) {
        APIService.shared.request(
            endpoint: "/family/permissionsFrom?permissionFrom=\(userId)",
            method: .get
        ) { (result: Result<FamilyPermission, Error>) in
            switch result {
            case .success(let permission):
                completion(permission)
            case .failure(let error):
                print("Error fetching permissions from user: \(error)")
                completion(nil)
            }
        }
    }

    func createPermissions(
        for userId: String,
        completion: @escaping (FamilyPermission?) -> Void
    ) {
        struct CreateBody: Encodable {
            let permissionTo: String
        }

        APIService.shared.request(
            endpoint: "/family/permissions",
            method: .post,
            body: CreateBody(permissionTo: userId)
        ) { (result: Result<FamilyPermission, Error>) in
            switch result {
            case .success(let permission):
                NotificationCenter.default.post(
                    name: NSNotification.Name(
                        NotificationNames.familyPermissionsUpdated
                    ),
                    object: nil
                )
                completion(permission)
            case .failure(let error):
                print("Error creating permissions: \(error)")
                completion(nil)
            }
        }
    }

    func updatePermissions(
        familyId: String,
        permissionTo userId: String,
        write: Bool,
        permissions: FamilyPermissionFlags,
        completion: @escaping (FamilyPermission?) -> Void
    ) {
        struct UpdateBody: Encodable {
            let permissionTo: String
            let write: Bool
            let permissions: FamilyPermissionFlags
        }

        APIService.shared.request(
            endpoint: "/family/\(familyId)/permissions",
            method: .put,
            body: UpdateBody(
                permissionTo: userId,
                write: write,
                permissions: permissions
            )
        ) { (result: Result<FamilyPermission, Error>) in
            switch result {
            case .success(let permission):
                NotificationCenter.default.post(
                    name: NSNotification.Name(
                        NotificationNames.familyPermissionsUpdated
                    ),
                    object: nil
                )
                completion(permission)
            case .failure(let error):
                print("Error updating permissions: \(error)")
                completion(nil)
            }
        }
    }

    func deletePermissions(
        for userId: String,
        completion: @escaping (Bool) -> Void
    ) {
        APIService.shared.request(
            endpoint: "/family/permissions?permissionTo=\(userId)",
            method: .delete
        ) { (result: Result<DeleteResponse, Error>) in
            switch result {
            case .success:
                NotificationCenter.default.post(
                    name: NSNotification.Name(
                        NotificationNames.familyPermissionsUpdated
                    ),
                    object: nil
                )
                completion(true)
            case .failure(let error):
                print("Error deleting permissions: \(error)")
                completion(false)
            }
        }
    }
}
