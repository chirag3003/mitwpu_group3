import Foundation

class ProfileService {

    static let shared = ProfileService()

    // Keep data in memory so the app can access it instantly without fetching every time
    private(set) var data: ProfileModel

    private init() {

        // Try to fetch from Core Data
        self.data = ProfileService.loadInitialData()

        // Fetch from API
        fetchProfileFromAPI()
    }

    private static func loadInitialData() -> ProfileModel {
        if let userEntity = CoreDataManager.shared.fetchUserProfile() {

            // Convert Core Data Entity to ProfileModel Struct

            let heightInt = Int(userEntity.height ?? "") ?? 0
            let weightInt = Int(userEntity.weight ?? "") ?? 0

            return ProfileModel(
                firstName: userEntity.firstName ?? "",
                lastName: userEntity.lastName ?? "",
                dob: userEntity.dob ?? Date(),
                sex: userEntity.sex ?? "Male",
                diabetesType: userEntity.diabetesType ?? "Type 2",
                bloodType: userEntity.bloodType ?? "O+",
                height: heightInt,
                weight: weightInt
            )

        } else {

            // If no Core Data found return default
            var dateComponents = DateComponents()
            dateComponents.year = 2005
            dateComponents.month = 12
            dateComponents.day = 2

            let calendar = Calendar(identifier: .gregorian)
            let date = calendar.date(from: dateComponents) ?? Date()

            return ProfileModel(
                firstName: "Chirag",
                lastName: "Bhalotia",
                dob: date,
                sex: "Male",
                diabetesType: "Type 2",
                bloodType: "AB+",
                height: 172,
                weight: 65
            )
        }
    }

    func getProfile() -> ProfileModel {
        return data
    }

    func setProfile(to newData: ProfileModel) {
        // Update In-Memory
        self.data = newData

        // Save to Core Data
        save()

        // Save to API
        saveToAPI(profile: newData)

        // Notify Listeners
        NotificationCenter.default.post(
            name: NSNotification.Name(NotificationNames.profileUpdated),
            object: nil
        )
    }

    private func save() {

        // Convert ProfileModel (Int) to Core Data (String)
        // If 0, save "Not Set" to keep logic clean, otherwise save the number string

        let hString = (data.height == 0) ? "Not Set" : "\(data.height)"
        let wString = (data.weight == 0) ? "Not Set" : "\(data.weight)"

        CoreDataManager.shared.saveProfile(
            firstName: data.firstName,
            lastName: data.lastName,
            dob: data.dob,
            sex: data.sex,
            diabetesType: data.diabetesType,
            bloodType: data.bloodType,
            height: hString,
            weight: wString
        )
    }

    // MARK: - API Integration

    func fetchProfileFromAPI() {
        APIService.shared.request(endpoint: "/profile", method: .get) {
            [weak self] (result: Result<ProfileModel, Error>) in
            guard let self = self else { return }

            switch result {
            case .success(let fetchedProfile):
                print("Fetched profile from API: \(fetchedProfile.firstName)")

                DispatchQueue.main.async {

                    // Update local data
                    self.data = fetchedProfile

                    // Sync to Core Data so it's available offline next time
                    self.save()

                    // Notify UI
                    NotificationCenter.default.post(
                        name: NSNotification.Name(
                            NotificationNames.profileUpdated
                        ),
                        object: nil
                    )
                }

            case .failure(let error):
                print("Error fetching profile: \(error)")
            }
        }
    }

    func saveToAPI(profile: ProfileModel) {

        let _: HTTPMethod = (profile.apiID != nil) ? .put : .post

        APIService.shared.request(
            endpoint: "/profile",
            method: .put,
            body: profile
        ) { [weak self] (result: Result<ProfileModel, Error>) in
            switch result {
            case .success(let savedProfile):
                print("Profile synced to API")
                // Update ID if we got a new one
                if let self = self, self.data.apiID == nil {
                    DispatchQueue.main.async {
                        self.data.apiID = savedProfile.apiID
                        self.data.userId = savedProfile.userId
                        self.save()  // Save ID to Core Data
                    }
                }

            case .failure(let error):
                print("Error syncing profile to API: \(error)")
            }
        }
    }
}
