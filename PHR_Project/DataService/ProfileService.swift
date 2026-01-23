import Foundation

class ProfileService {
    
    static let shared = ProfileService()
    
    // We keep 'data' in memory so the app can access it instantly without fetching every time
    private(set) var data: ProfileModel
    
    private init() {
        // 1. Try to fetch from Core Data
        self.data = ProfileService.loadInitialData()
        
        // 2. Fetch from API (Async)
        fetchProfileFromAPI()
    }

    private static func loadInitialData() -> ProfileModel {
        if let userEntity = CoreDataManager.shared.fetchUserProfile() {
            
            // 2. Convert Core Data Entity -> ProfileModel Struct
            // We interpret "0" or "Not Set" strings as integer 0
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
            // 3. No Core Data found? Load Defaults (Your original logic)
            var dateComponents = DateComponents()
            dateComponents.year = 2005
            dateComponents.month = 12
            dateComponents.day = 2
            
            let calendar = Calendar(identifier: .gregorian)
            let date = calendar.date(from: dateComponents) ?? Date()

            return ProfileModel(
                firstName: "Ved",
                lastName: "Chavan",
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
        // 1. Update In-Memory
        self.data = newData
        
        // 2. Save to Core Data
        save()
        
        // 3. Save to API
        saveToAPI(profile: newData)
        
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
    
    // MARK: - API Integration
    
    func fetchProfileFromAPI() {
        APIService.shared.request(endpoint: "/profile", method: .get) { [weak self] (result: Result<ProfileModel, Error>) in
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
                    NotificationCenter.default.post(name: NSNotification.Name(NotificationNames.profileUpdated), object: nil)
                }
                
            case .failure(let error):
                print("Error fetching profile: \(error)")
            }
        }
    }
    
    func saveToAPI(profile: ProfileModel) {
        // Determine if we should POST (create) or PUT (update)
        // Since the backend documentation shows separate endpoints but typically profile is singular
        // The /profile endpoints: PUT updates current user. POST creates new.
        // We'll try PUT first since a user likely exists if they are using the app? 
        // Or cleaner: If we have an apiID, use PUT? Wait, PUT /profile doesn't take ID in URL per docs?
        // Checking docs:
        // GET /profile -> Current User
        // PUT /profile -> Update Current User
        // POST /profile -> Create New Profile (if none)
        // To be safe, we can try PUT. If 404, try POST? Or just use PUT as default for updates.
        
        let method: HTTPMethod = (profile.apiID != nil) ? .put : .post
        
        // Actually, for simplicity and since we are updating "Current User", PUT is likely the way for edits.
        // Docs say: PUT /profile "Update the current user's profile".
        
        APIService.shared.request(endpoint: "/profile", method: .put, body: profile) { [weak self] (result: Result<ProfileModel, Error>) in
             switch result {
             case .success(let savedProfile):
                 print("Profile synced to API")
                 // Update ID if we got a new one
                 if let self = self, self.data.apiID == nil {
                     DispatchQueue.main.async {
                         self.data.apiID = savedProfile.apiID
                         self.data.userId = savedProfile.userId
                         self.save() // Save ID to Core Data
                     }
                 }
                 
             case .failure(let error):
                 print("Error syncing profile to API: \(error)")
             }
        }
    }
}
