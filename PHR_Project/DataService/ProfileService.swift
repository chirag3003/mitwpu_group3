import Foundation

class ProfileService {
    static let shared = ProfileService()

    private var data: ProfileModel
    
    init(){
        var dateComponents = DateComponents()
        dateComponents.year = 2005
        dateComponents.month = 6 // June
        dateComponents.day = 30

        // Optionally, specify the time zone. If omitted, Calendar.current's time zone is used.
        // Setting time components to 00:00:00 UTC often provides a consistent base.
        dateComponents.hour = 0
        dateComponents.minute = 0
        dateComponents.second = 0
        dateComponents.timeZone = TimeZone(abbreviation: "UTC") // Use UTC for consistency

        // 2. Use the Calendar to create the Date
        let calendar = Calendar(identifier: .gregorian) // Use the Gregorian calendar

        let date = calendar.date(from: dateComponents)
       
        
        data = ProfileModel(
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
    
    func getProfile() -> ProfileModel {
        return data
    }
    
    func setProfile(to data: ProfileModel) {
        self.data = data
    }
}
