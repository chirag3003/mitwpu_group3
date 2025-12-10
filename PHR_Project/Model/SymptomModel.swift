//
//  SymptomModel.swift
//  PHR_Project
//
//  Created by SDC_USER on 28/11/25.
//

import Foundation

// 1. Delete the 'struct CustomDate' block entirely. You don't need it.

// 2. Update the Main Symptom Struct to use Foundation.Date explicitly
struct Symptom: Codable {
    var id: UUID?
    var symptomName: String
    var intensity: String
    var dateRecorded: Foundation.Date  // Ensure this is Foundation.Date
    var notes: String?
    var time: DateComponents
}

struct Symptoms {
    var allSymptoms: [Symptom]
}
