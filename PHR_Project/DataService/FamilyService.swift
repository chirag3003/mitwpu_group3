import Foundation

class FamilyService {
    static let shared = FamilyService()

    private var familyMembers: [FamilyMember] = []

    private init() {
        familyMembers = [
            FamilyMember(
                name: "Chirag",
                imageName: "https://phr.chirag.codes/uploads/1770102863293-Chirag.png",
                isMe: false
            ),
            FamilyMember(
                name: "Ved",
                imageName: "https://phr.chirag.codes/uploads/1770102863371-Ved.png",
                isMe: false
            ),
            FamilyMember(
                name: "Sushant",
                imageName: "https://phr.chirag.codes/uploads/1770102863358-Sushant.png",
                isMe: false
            ),
            FamilyMember(
                name: "Sanchita",
                imageName: "https://phr.chirag.codes/uploads/1770102863343-Sanchita.jpeg",
                isMe: false
            ),
        ]
    }

    func getAllMembers() -> [FamilyMember] {
        return familyMembers
    }
}
