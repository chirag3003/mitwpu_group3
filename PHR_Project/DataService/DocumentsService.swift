//
//  DocumentsService.swift
//  PHR_Project
//
//  Created by SDC-USER on 23/01/26.
//

import Foundation

class DocumentService {
    static let shared = DocumentService()
    
    private var documents: [Document] = []
    
    private init() {
        fetchDocumentsFromAPI()
    }
    
    // MARK: - Public Accessors
    
    func getAllDocuments() -> [Document] {
        return documents
    }
    
    func getPrescriptions() -> [Document] {
        return documents.filter { $0.documentType == .prescription }
    }
    
    func getReports() -> [Document] {
        return documents.filter { $0.documentType == .report }
    }
    
    func getDocumentsByDoctor(doctorId: String) -> [Document] {
        return documents.filter { $0.docDoctor?.apiID == doctorId || $0.docDoctorId == doctorId }
    }
    
    // MARK: - Legacy Compatibility Methods
    
    /// Returns list of unique doctors from prescriptions (for UI doctor list)
    func getAllPrescriptions() -> [documentsModel] {
        let prescriptions = getPrescriptions()
        
        // Group by doctor and get unique doctors
        var seenDoctors = Set<String>()
        var doctorList: [documentsModel] = []
        
        for doc in prescriptions {
            if let doctorId = doc.docDoctor?.apiID, !seenDoctors.contains(doctorId) {
                seenDoctors.insert(doctorId)
                doctorList.append(doc.asLegacyDocumentsModel)
            }
        }
        
        return doctorList
    }
    
    func getAllReports() -> [ReportModel] {
        return getReports().map { $0.asLegacyReportModel }
    }
    
    // MARK: - API Methods
    
    func fetchDocumentsFromAPI() {
        APIService.shared.request(endpoint: "/documents", method: .get) { [weak self] (result: Result<[Document], Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let fetched):
                self.documents = fetched
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: NSNotification.Name("DocumentsUpdated"), object: nil)
                }
            case .failure(let error):
                print("Error fetching documents: \(error)")
            }
        }
    }
    
    func deleteDocument(id: String) {
        // Optimistic delete
        documents.removeAll { $0.apiID == id }
        NotificationCenter.default.post(name: NSNotification.Name("DocumentsUpdated"), object: nil)
        
        struct EmptyResponse: Decodable {}
        APIService.shared.request(endpoint: "/documents/\(id)", method: .delete) { (result: Result<EmptyResponse, Error>) in
            if case .failure(let error) = result {
                print("Error deleting document: \(error)")
            }
        }
    }
    
    // MARK: - Upload Methods
    
    func uploadPrescription(fileData: Data, fileName: String, doctorId: String, date: Date, completion: @escaping (Bool) -> Void) {
        APIService.shared.uploadDocument(
            fileData: fileData,
            fileName: fileName,
            mimeType: "application/pdf",
            documentType: "Prescription",
            docDoctorId: doctorId,
            title: nil,
            date: date
        ) { [weak self] (result: Result<Document, Error>) in
            switch result {
            case .success(let doc):
                self?.documents.append(doc)
                NotificationCenter.default.post(name: NSNotification.Name("DocumentsUpdated"), object: nil)
                completion(true)
            case .failure(let error):
                print("Error uploading prescription: \(error)")
                completion(false)
            }
        }
    }
    
    func uploadReport(fileData: Data, fileName: String, title: String, date: Date, completion: @escaping (Bool) -> Void) {
        APIService.shared.uploadDocument(
            fileData: fileData,
            fileName: fileName,
            mimeType: "application/pdf",
            documentType: "Report",
            docDoctorId: nil,
            title: title,
            date: date
        ) { [weak self] (result: Result<Document, Error>) in
            switch result {
            case .success(let doc):
                self?.documents.append(doc)
                NotificationCenter.default.post(name: NSNotification.Name("DocumentsUpdated"), object: nil)
                completion(true)
            case .failure(let error):
                print("Error uploading report: \(error)")
                completion(false)
            }
        }
    }
}

// MARK: - PrescriptionService (Legacy Compatibility)

class PrescriptionService {
    static let shared = PrescriptionService()
    
    private init() {}
    
    func getAllPrescriptionData() -> [PrescriptionModel] {
        return DocumentService.shared.getPrescriptions().map { $0.asLegacyPrescriptionModel }
    }
    
    func getPrescriptionsByDoctor(_ doctorName: String) -> [PrescriptionModel] {
        return DocumentService.shared.getPrescriptions()
            .filter { $0.docDoctor?.name == doctorName }
            .map { $0.asLegacyPrescriptionModel }
    }
}
