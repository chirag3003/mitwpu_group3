//
//  DocumentsModel.swift
//  PHR_Project
//
//  Created by SDC-USER on 26/11/25.
//

import Foundation

// MARK: - DocDoctor Model (for /docDoctors API)

struct DocDoctor: Codable {
    var apiID: String?
    var name: String
    
    enum CodingKeys: String, CodingKey {
        case apiID = "_id"
        case name
    }
    
    init(apiID: String? = nil, name: String) {
        self.apiID = apiID
        self.name = name
    }
}

// MARK: - Document Model (for /documents API)

enum DocumentType: String, Codable {
    case prescription = "Prescription"
    case report = "Report"
}

struct Document: Codable {
    var apiID: String?
    var documentType: DocumentType
    var docDoctor: DocDoctor?   // Populated doctor object (GET responses)
    var docDoctorId: String?    // Doctor ID string (for POST requests)
    var title: String?          // For Reports
    var date: Date
    var fileUrl: String
    var fileSize: String?
    
    enum CodingKeys: String, CodingKey {
        case apiID = "_id"
        case documentType
        case docDoctor = "docDoctorId"  // API populates this as object
        case title
        case date
        case fileUrl
        case fileSize
    }
    
    init(apiID: String? = nil, documentType: DocumentType, docDoctor: DocDoctor? = nil, docDoctorId: String? = nil, title: String? = nil, date: Date, fileUrl: String, fileSize: String? = nil) {
        self.apiID = apiID
        self.documentType = documentType
        self.docDoctor = docDoctor
        self.docDoctorId = docDoctorId
        self.title = title
        self.date = date
        self.fileUrl = fileUrl
        self.fileSize = fileSize
    }
    
    // Custom decoder to handle both populated object and string ID
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.apiID = try container.decodeIfPresent(String.self, forKey: .apiID)
        self.documentType = try container.decode(DocumentType.self, forKey: .documentType)
        self.title = try container.decodeIfPresent(String.self, forKey: .title)
        self.date = try container.decode(Date.self, forKey: .date)
        self.fileUrl = try container.decode(String.self, forKey: .fileUrl)
        self.fileSize = try container.decodeIfPresent(String.self, forKey: .fileSize)
        
        // Handle docDoctorId as either object or string
        if let doctor = try? container.decode(DocDoctor.self, forKey: .docDoctor) {
            self.docDoctor = doctor
            self.docDoctorId = doctor.apiID
        } else if let doctorId = try? container.decode(String.self, forKey: .docDoctor) {
            self.docDoctorId = doctorId
            self.docDoctor = nil
        } else {
            self.docDoctor = nil
            self.docDoctorId = nil
        }
    }
}

// MARK: - UI Compatibility Extensions

extension Document {
    /// Formatted date string for UI display
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM yyyy"
        return formatter.string(from: date)
    }
    
    /// For legacy UI: Convert to documentsModel (doctor list item)
    var asLegacyDocumentsModel: documentsModel {
        return documentsModel(
            id: UUID(),
            title: docDoctor?.name ?? "Unknown Doctor",
            lastUpdatedAt: formattedDate
        )
    }
    
    /// For legacy UI: Convert to PrescriptionModel (prescription detail)
    var asLegacyPrescriptionModel: PrescriptionModel {
        return PrescriptionModel(
            id: UUID(),
            title: title ?? "Prescription",
            doctorName: docDoctor?.name ?? "",
            lastUpdatedAt: formattedDate,
            fileSize: fileSize ?? "",
            pdfUrl: fileUrl
        )
    }
    
    /// For legacy UI: Convert to ReportModel
    var asLegacyReportModel: ReportModel {
        return ReportModel(
            id: UUID(),
            apiID: apiID,
            title: title ?? "Report",
            lastUpdatedAt: formattedDate,
            pdfUrl: fileUrl
        )
    }
}

// MARK: - Legacy Models (kept for UI compatibility)

struct documentsModel: Codable {
    let id: UUID
    let title: String
    let lastUpdatedAt: String
}

struct ReportModel {
    let id: UUID
    var apiID: String?  // API ID for delete operations
    let title: String
    let lastUpdatedAt: String
    var pdfUrl: String?
}

struct PrescriptionModel {
    let id: UUID
    let title: String
    let doctorName: String
    let lastUpdatedAt: String
    let fileSize: String
    var pdfUrl: String?
}
