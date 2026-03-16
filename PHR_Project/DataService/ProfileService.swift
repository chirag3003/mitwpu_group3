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
                weight: weightInt,
                profileImage: userEntity.profileImage
            )

        } else {

            // No Core Data record — return blank defaults
            return ProfileModel(
                firstName: "",
                lastName: "",
                dob: Date(),
                sex: "",
                diabetesType: "",
                bloodType: "",
                height: 0,
                weight: 0
            )
        }
    }

    func getProfile() -> ProfileModel {
        return data
    }

    func setProfile(to newData: ProfileModel, imageData: Data? = nil) {
        // Update In-Memory
        self.data = newData

        // Save to Core Data
        save()

        // Save to API
        saveToAPI(profile: newData, imageData: imageData)

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
            [weak self] (result: Result<ProfileModel?, Error>) in
            guard let self = self else { return }

            switch result {
            case .success(let fetchedProfile):
                guard let fetchedProfile = fetchedProfile else {
                    print("No profile on server yet (null response)")
                    return
                }
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

    func saveToAPI(profile: ProfileModel, imageData: Data? = nil) {

        let method: HTTPMethod = (profile.apiID != nil) ? .put : .post

        // 1. Check if we have an image to upload first
        if let imageData = imageData {
            // Upload Image
            APIService.shared.upload(
                endpoint: "/profile/image",
                method: "PUT",
                data: imageData,
                filename: "profile.jpg",
                fieldName: "profileImage"
            ) { [weak self] (result: Result<ProfileModel, Error>) in
                guard let self = self else { return }

                switch result {
                case .success(let updatedProfile):
                    print("Image uploaded successfully")
                    // The backend returns the updated profile with the image URL
                    // We update our local model with this URL
                    var finalProfile = profile
                    finalProfile.profileImage = updatedProfile.profileImage

                    // 2. Now save the rest of the text data
                    self.performTextSave(profile: finalProfile, method: method)

                case .failure(let error):
                    print("Error uploading profile image: \(error)")
                    // Even if image fails, try to save text data?
                    // Or stop here. Let's try saving text data anyway.
                    self.performTextSave(profile: profile, method: method)
                }
            }
        } else {
            // No image to upload, just save text
            performTextSave(profile: profile, method: method)
        }
    }

    private func performTextSave(profile: ProfileModel, method: HTTPMethod) {
        APIService.shared.request(
            endpoint: "/profile",
            method: method,
            body: profile
        ) { [weak self] (result: Result<ProfileModel, Error>) in
            switch result {
            case .success(let savedProfile):
                print("Profile text synced to API")
                if let self = self {
                    DispatchQueue.main.async {
                        // Merge the response (which has the correct ID and potentially Image URL)
                        // back into our local store
                        self.data = savedProfile

                        self.save()  // Save to Core Data

                        // Notify listeners
                        NotificationCenter.default.post(
                            name: NSNotification.Name(
                                NotificationNames.profileUpdated
                            ),
                            object: nil
                        )
                    }
                }

            case .failure(let error):
                print("Error syncing profile text to API: \(error)")
            }
        }
    }
}
