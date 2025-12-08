//
//  SymptomModel.swift
//  PHR_Project
//
//  Created by SDC_USER on 28/11/25.
//

import Foundation

// 1. Your Custom Date Struct (Based on your datasource usage)
struct CustomDate {
    let day: String    // "Mon,"
    let number: String // "16th"
}

// 2. The Main Symptom Struct
struct Symptom {
    var symptomName: String
    var intensity: String
    var dateRecorded: CustomDate // Using the custom struct above
    var notes: String?
    var time: DateComponents
}

// 3. The Container (Optional, but matches your 'symptoms: Symptoms(...)' pattern)
struct Symptoms {
    var allSymptoms: [Symptom]
}
