import Foundation

class FamilyService {
    static let shared = FamilyService()

    private var familyMembers: [FamilyMember] = []

    private init() {
        familyMembers = [
            FamilyMember(
                name: "Chirag",
                imageName: "https://phr.chirag.codes/uploads/1770713598905-Chirag.png"
            ),
            FamilyMember(
                name: "Ved",
                imageName: "https://phr.chirag.codes/uploads/1770713598968-Ved.png"
            ),
            FamilyMember(
                name: "Sushant",
                imageName: "https://phr.chirag.codes/uploads/1770713598949-Sushant.png"
            ),
            FamilyMember(
                name: "Sanchita",
                imageName: "https://phr.chirag.codes/uploads/1770713598929-Sanchita.jpeg"
            ),
        ]
    }

    func getAllMembers() -> [FamilyMember] {
        return familyMembers
    }
}
