//
//  DocumentsModel.swift
//  PHR_Project
//
//  Created by SDC-USER on 26/11/25.
//

import Foundation


struct documentsModel: Codable {
    
    let id: UUID
    let title: String
    let lastUpdatedAt: String
    
}

struct ReportModel {
    let id: UUID
    let title: String
    let lastUpdatedAt: String
    let fileSize: String
}


struct PrescriptionModel {
    let id: UUID
    let title: String
    let doctorName: String
    let lastUpdatedAt: String
    let fileSize: String
    var pdfUrl: String?
}   
