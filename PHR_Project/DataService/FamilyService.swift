import Foundation

class FamilyService {
    static let shared = FamilyService()

    private var familyMembers: [FamilyMember] = []

    private init() {
        familyMembers = [
            FamilyMember(
                name: "Chirag",
                imageName: "https://phr.chirag.codes/uploads/1769583482384-Chirag.png",
                isMe: false
            ),
            FamilyMember(
                name: "Ved",
                imageName: "https://phr.chirag.codes/uploads/1769583482463-Ved.png",
                isMe: false
            ),
            FamilyMember(
                name: "Sushant",
                imageName: "https://phr.chirag.codes/uploads/1769583482454-Sushant.png",
                isMe: false
            ),
            FamilyMember(
                name: "Sanchita",
                imageName: "https://phr.chirag.codes/uploads/1769583482442-Sanchita.jpeg",
                isMe: false
            ),
        ]
    }

    func getAllMembers() -> [FamilyMember] {
        return familyMembers
    }
}
