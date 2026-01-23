import Foundation

class FamilyService {
    static let shared = FamilyService()

    private var familyMembers: [FamilyMember] = []

    private init() {
        familyMembers = [
            FamilyMember(name: "Ved", imageName: "https://drive.google.com/file/d/1LcEPDDxhZR6i2wA9wFO75791Fg1JwfAW/view?usp=share_link", isMe: false),
            FamilyMember(name: "Sushant", imageName: "https://drive.google.com/file/d/1TNlQlNRhf6aFEKhTDDBI9IMN7z71qGI6/view?usp=share_link", isMe: false),
            FamilyMember(name: "Chirag", imageName: "https://drive.google.com/file/d/1Gl6qxbMPs8FVeRFuCid5I1xhoImE4Jak/view?usp=share_link", isMe: false),
            FamilyMember(name: "Sanchita", imageName: "https://drive.google.com/file/d/1rrCbEMetZk0aHQtbPRnG80pJuE8oYZ5h/view?usp=share_link", isMe: false),
        ]
    }
    
    func getAllMembers() -> [FamilyMember]{
        return familyMembers
    }
}
