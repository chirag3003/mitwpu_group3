//
//  GlucoseModel.swift
//  PHR_Project
//
//  Created by SDC_USER on 20/01/26.
//

import Foundation


struct GlucoseDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let value: Int 
}
