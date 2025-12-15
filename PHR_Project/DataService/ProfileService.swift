import Foundation


class ProfileService {
    static let shared = ProfileService()
    private let storageKey = StorageKeys.profile
    private var data: ProfileModel {
        didSet{
            save()
            NotificationCenter.default.post(name: NSNotification.Name(NotificationNames.profileUpdated), object: nil)
        }
    }
    
    
    private init() {
        if let savedData = UserDefaults.standard.data(forKey: storageKey),
            let decodedModel = try? JSONDecoder().decode(
                ProfileModel.self,
                from: savedData
            )
        {
            // Using saved data
            self.data = decodedModel
        } else {
            // If no data exists, load the default (User's code)
            var dateComponents = DateComponents()
            dateComponents.year = 2005
            dateComponents.month = 6
            dateComponents.day = 30
            dateComponents.hour = 0
            dateComponents.minute = 0
            dateComponents.second = 0
            dateComponents.timeZone = TimeZone(abbreviation: "UTC")

            let calendar = Calendar(identifier: .gregorian)
            let date = calendar.date(from: dateComponents)

            self.data = ProfileModel(
                firstName: "Chirag",
                lastName: "Bhalotia",
                dob: date!,
                sex: "Male",
                diabetesType: "Type 2",
                bloodType: "B+",
                height: 172,
                weight: 65
            )
        }
    }

    func getProfile() -> ProfileModel {
        return data
    }

    func setProfile(to data: ProfileModel) {
        self.data = data
    }

    // MARK: - Persistence Helper
    private func save() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(self.data)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            print("Failed to save profile: \(error)")
        }
    }
}
