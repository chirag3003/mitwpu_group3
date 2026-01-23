import Foundation

class FamilyService {
    static let shared = FamilyService()

    private var familyMembers: [FamilyMember] = []

    private init() {
        familyMembers = [
            FamilyMember(
                name: "Ved",
                imageName:
                    "https://phr.chirag.codes/uploads/1769158255033-Ved.png",
                isMe: false
            ),
            FamilyMember(
                name: "Sushant",
                imageName:
                    "https://phr.chirag.codes/uploads/1769158254993-Sushant.png",
                isMe: false
            ),
            FamilyMember(
                name: "Chirag",
                imageName:
                    "https://phr.chirag.codes/uploads/1769158255001-Chirag.png",
                isMe: false
            ),
            FamilyMember(
                name: "Sanchita",
                imageName:
                    "https://phr.chirag.codes/uploads/1769158254962-Sanchita.jpeg",
                isMe: false
            ),
        ]
    }

    func getAllMembers() -> [FamilyMember] {
        return familyMembers
    }
}
