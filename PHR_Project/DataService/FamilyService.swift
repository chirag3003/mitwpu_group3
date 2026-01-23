import Foundation

class FamilyService {
    static let shared = FamilyService()

    private var familyMembers: [FamilyMember] = []

    private init() {
        familyMembers = [
            FamilyMember(name: "Dad", imageName: "person.fill", isMe: true),
            FamilyMember(name: "Mom", imageName: "person.fill", isMe: false),
            FamilyMember(name: "Ved", imageName: "person.fill", isMe: false),
            FamilyMember(name: "Sushi", imageName: "person.fill", isMe: false),
            FamilyMember(name: "Chintu", imageName: "person.fill", isMe: false),
            FamilyMember(name: "Tosh", imageName: "person.fill", isMe: false),
        ]
    }
    
    func getAllMembers() -> [FamilyMember]{
        return familyMembers
    }
}
