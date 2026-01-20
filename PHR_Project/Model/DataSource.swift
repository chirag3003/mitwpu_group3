import Foundation

struct DataSource {
    var profile: Profile
    let document: Document
    let family: Family
    let symptoms: Symptoms
}

struct Profile {
    let allergies: [Allergy]
}

struct Document {
    let prescriptions: [documentsModel]
    let reports: [ReportModel]
    let prescriptionData : [PrescriptionModel]
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
    // Helper to build a concrete Date from components
    func makeDate(year: Int, month: Int, day: Int, hour: Int, minute: Int) -> Foundation.Date {
        var comps = DateComponents()
        comps.year = year
        comps.month = month
        comps.day = day
        comps.hour = hour
        comps.minute = minute
        return Calendar.current.date(from: comps) ?? Date()
    }

    return DataSource(
        profile: Profile(
            allergies: [
                Allergy(id: nil, name: "Peanuts", severity: "High", notes: "Difficulty in Breathing"),
                Allergy(id: nil, name: "Dust", severity: "Medium", notes: "Causes sneezing, runny nose"),
                Allergy(id: nil, name: "Pollen", severity: "Low", notes: "Seasonal allergy during spring")
            ]
        ),
        document: Document(
            prescriptions: [
                documentsModel(id: UUID(), title: "Dr. Abhishek Khare", lastUpdatedAt: "18 Nov 2025"),
                documentsModel(id: UUID(), title: "Dr. Rutuja Khare", lastUpdatedAt: "7 Nov 2025")
            ],
            reports: [
                ReportModel(id: UUID(), title: "HbA1c", lastUpdatedAt: "15 Nov 2025", fileSize: "3MB"),
                ReportModel(id: UUID(), title: "Sugar", lastUpdatedAt: "16 Jan 2025", fileSize: "5MB")
            ],
            // MARK: - FIXED SECTION BELOW
            prescriptionData: [
                PrescriptionModel(
                    id: UUID(),
                    title: "HbA1c Report",
                    doctorName: "Dr. Abhishek Khare",
                    lastUpdatedAt: "16 Nov 2025",
                    fileSize: "6MB",
                    pdfUrl: "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf"
                ),
                PrescriptionModel(
                    id: UUID(),
                    title: "TSH Report",
                    doctorName: "Dr. Rutuja Khare",
                    lastUpdatedAt: "17 Nov 2025",
                    fileSize: "8MB",
                    pdfUrl: "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf"
                ),
                PrescriptionModel(
                    id: UUID(),
                    title: "CMP Report",
                    doctorName: "Dr. Abhishek Khare",
                    lastUpdatedAt: "18 Nov 2025",
                    fileSize: "4MB",
                    pdfUrl: "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf"
                )
            ]
        ),
        family: Family(
            members: [
                FamilyMember(name: "Dad", imageName: "person.fill", isMe: true),
                FamilyMember(name: "Mom", imageName: "person.fill", isMe: false),
                FamilyMember(name: "Ved", imageName: "person.fill", isMe: false),
                FamilyMember(name: "Sushi", imageName: "person.fill", isMe: false),
                FamilyMember(name: "Chintu", imageName: "person.fill", isMe: false),
                FamilyMember(name: "Tosh", imageName: "person.fill", isMe: false)
            ],
            contacts: [
                Contact(name: "Chirag", image: "", phoneNum: "+91 7044521050"),
                Contact(name: "Sakshi", image: "", phoneNum: "+91 9970001033"),
                Contact(name: "Ved", image: "", phoneNum: "+91 9284612186")
            ]
        ),
        symptoms: Symptoms(
            allSymptoms: [
                Symptom(
                    id: UUID(),
                    symptomName: "Fever",
                    intensity: "High",
                    dateRecorded: makeDate(year: 2025, month: 11, day: 16, hour: 19, minute: 30),
                    notes: "Felt chills in the evening",
                    time: DateComponents(hour: 19, minute: 30)
                ),
                Symptom(
                    id: UUID(),
                    symptomName: "Headache",
                    intensity: "Medium",
                    dateRecorded: makeDate(year: 2025, month: 11, day: 17, hour: 10, minute: 15),
                    notes: "Throbbing pain, relieved by rest",
                    time: DateComponents(hour: 10, minute: 15)
                )
            ]
        )
    )
}
