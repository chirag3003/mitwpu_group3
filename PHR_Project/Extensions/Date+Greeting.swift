//
//  Date+Greeting.swift
//  PHR_Project
//
//  Created on 23/01/26.
//

import Foundation

extension Date {
    /// Returns a greeting based on time of day (Morning, Afternoon, or Evening)
    var greetingText: String {
        let hour = Calendar.current.component(.hour, from: self)
        switch hour {
        case 0..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        default: return "Good Evening"
        }
    }
}
