import Foundation

class FamilyService {
    static let shared = FamilyService()

    private var familyMembers: [FamilyMember] = []

    private init() {
        familyMembers = [
            FamilyMember(
                name: "Chirag",
                imageName: "http://phr.chirag.codes/uploads/1770713598905-Chirag.png",
                isMe: false
            ),
            FamilyMember(
                name: "Ved",
                imageName: "http://phr.chirag.codes/uploads/1770713598968-Ved.png",
                isMe: false
            ),
            FamilyMember(
                name: "Sushant",
                imageName: "http://phr.chirag.codes/uploads/1770713598949-Sushant.png",
                isMe: false
            ),
            FamilyMember(
                name: "Sanchita",
                imageName: "http://phr.chirag.codes/uploads/1770713598929-Sanchita.jpeg",
                isMe: false
            ),
        ]
    }

    func getAllMembers() -> [FamilyMember] {
        return familyMembers
    }
}
