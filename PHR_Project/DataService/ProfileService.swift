import Foundation

class ProfileService {
    
    static let shared = ProfileService()
    
    // We keep 'data' in memory so the app can access it instantly without fetching every time
    private(set) var data: ProfileModel
    
    private init() {
        // 1. Try to fetch from Core Data
        if let userEntity = CoreDataManager.shared.fetchUserProfile() {
            
            // 2. Convert Core Data Entity -> ProfileModel Struct
            // We interpret "0" or "Not Set" strings as integer 0
            let heightInt = Int(userEntity.height ?? "") ?? 0
            let weightInt = Int(userEntity.weight ?? "") ?? 0
            
            self.data = ProfileModel(
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
            // 3. No Core Data found? Load Defaults (Your original logic)
            var dateComponents = DateComponents()
            dateComponents.year = 2005
            dateComponents.month = 6
            dateComponents.day = 30
            
            let calendar = Calendar(identifier: .gregorian)
            let date = calendar.date(from: dateComponents) ?? Date()

            self.data = ProfileModel(
                firstName: "Chirag",
                lastName: "Bhalotia",
                dob: date,
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

    func setProfile(to newData: ProfileModel) {
        // 1. Update In-Memory
        self.data = newData
        
        // 2. Save to Core Data
        save()
        
        // 3. Notify Listeners
        NotificationCenter.default.post(name: NSNotification.Name(NotificationNames.profileUpdated), object: nil)
    }

    private func save() {
        // Convert ProfileModel (Int) -> Core Data (String)
        // If 0, we save "Not Set" to keep your UI logic clean, otherwise save the number string
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
}
