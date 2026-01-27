//
//  DocumentsService.swift
//  PHR_Project
//
//  Created by SDC-USER on 23/01/26.
//

import Foundation

class DocumentService {
    static let shared = DocumentService()
    
    private var prescriptions: [documentsModel] = []
    private var reports: [ReportModel] = []
    
    private init() {
        prescriptions = [
            documentsModel(id: UUID(), title: "Dr. Abhishek Khare", lastUpdatedAt: "18 Nov 2025"),
            documentsModel(id: UUID(), title: "Dr. Rutuja Khare", lastUpdatedAt: "7 Nov 2025")
        ]
        
        reports = [
            ReportModel(id: UUID(), title: "HbA1c", lastUpdatedAt: "15 Nov 2025"),
            ReportModel(id: UUID(), title: "Sugar", lastUpdatedAt: "16 Jan 2025")
        ]
    }
    
    func getAllPrescriptions() -> [documentsModel] {
        return prescriptions
    }
    
    func getAllReports() -> [ReportModel] {
        return reports
    }
    
}

class PrescriptionService {
    static let shared = PrescriptionService()
    
    private var prescriptionData: [PrescriptionModel] = []
    
    private init() {
        prescriptionData = [
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
    }
    
    func getAllPrescriptionData() -> [PrescriptionModel] {
        return prescriptionData
    }
    
    func getPrescriptionsByDoctor(_ doctorName: String) -> [PrescriptionModel] {
        return prescriptionData.filter { $0.doctorName == doctorName }
    }
}
