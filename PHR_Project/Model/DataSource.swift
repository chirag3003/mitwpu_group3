import Foundation

struct DataSource {
    let document: Document
}

struct Document {
    let prescriptions: [documentsModel]
    let reports: [ReportModel]
    let prescriptionData : [PrescriptionModel]
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

    return DataSource(        document: Document(
            prescriptions: [
                documentsModel(id: UUID(), title: "Dr. Abhishek Khare", lastUpdatedAt: "18 Nov 2025"),
                documentsModel(id: UUID(), title: "Dr. Rutuja Khare", lastUpdatedAt: "7 Nov 2025")
            ],
            reports: [
                ReportModel(id: UUID(), title: "HbA1c", lastUpdatedAt: "15 Nov 2025"),
                ReportModel(id: UUID(), title: "Sugar", lastUpdatedAt: "16 Jan 2025")
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
    )
}

