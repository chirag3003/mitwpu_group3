import Foundation

struct DataSource {
    var profile: Profile
    let document: Document
    let family: Family
//    let meal: MealScreen
}

struct Profile {
    let allergies: [Allergy]
}

struct Document {
    let prescriptions: [documentsModel]
    let reports: [ReportModel]
}

struct Family {
    let members: [FamilyMember]
    let contacts: [Contact]
}

struct MealScreen {
    let mealItems: [MealItem]
    let mealDetails: [MealDetails]
}

func getAllData() -> DataSource {
    return DataSource(
        profile: Profile(
            allergies: [
                Allergy(
                    name: "Peanuts",
                    severity: "High",
                    notes: "Difficulty in Breathing"
                ),
                Allergy(
                    name: "Dust",
                    severity: "Medium",
                    notes: "Causes sneezing, runny nose"
                ),
                Allergy(
                    name: "Pollen",
                    severity: "Low",
                    notes: "Seasonal allergy during spring"
                ),
            ],
        ),
        
        document: Document(
            prescriptions: [
                documentsModel(
                    id: UUID(),
                    title: "Dr. Abhishek Khare",
                    lastUpdatedAt: "15 Nov 2025"
                ),
                documentsModel(
                    id: UUID(),
                    title: "Dr. B",
                    lastUpdatedAt: "16 Nov 2025"
                ),
                documentsModel(
                    id: UUID(),
                    title: "Dr. C",
                    lastUpdatedAt: "18 Nov 2025"
                ),
                documentsModel(
                    id: UUID(),
                    title: "Dr. D",
                    lastUpdatedAt: "19 Nov 2025"
                ),
                documentsModel(
                    id: UUID(),
                    title: "Dr. E",
                    lastUpdatedAt: "20 Nov 2025"
                ),
            ],
            reports: [
                ReportModel(
                    id: UUID(),
                    title: "H1ABC",
                    lastUpdatedAt: "15 Nov 2025",
                    fileSize: "3MB"
                ),
                ReportModel(
                    id: UUID(),
                    title: "Sugar",
                    lastUpdatedAt: "16 Nov 2025",
                    fileSize: "5MB"
                ),
            ]
        ),
        family: Family(
            members: [
                FamilyMember(name: "Dad", imageName: "person.fill", isMe: true),
                FamilyMember(name: "Mom", imageName: "person.fill", isMe: false),
                FamilyMember(name: "Ved", imageName: "person.fill", isMe: false),
                FamilyMember(name: "Sushi", imageName: "person.fill", isMe: false),
                FamilyMember(name: "Chintu", imageName: "person.fill", isMe: false),
                FamilyMember(name: "Tosh", imageName: "person.fill", isMe: false),
            ], contacts:[
                Contact(name: "Chirag", image: "", phoneNum: "+91 7044521050"),
                Contact(name: "Sakshi", image: "", phoneNum: "+91 9970001033"),
                Contact(name: "Ved", image: "", phoneNum: "+91 9284612186")
            ]
        ),
//        meal: 
    )
}
