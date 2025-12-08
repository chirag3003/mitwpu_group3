//
//  AllergyModel.swift
//  PHR_Project
//
//  Created by SDC_USER on 27/11/25.
//

import Foundation


struct Allergy: Codable {
    var id: UUID?
    var name: String
    var severity: String
    var notes: String?
}
