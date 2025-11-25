//
//  FamilyModel.swift
//  PHR_Project
//
//  Created by Sushant Pulipati on 24/11/25.
//

import Foundation

//struct FamilyMember {
//    var id: String
//    var name: String
//    var memoji: String
//    var relation: String?
//}

struct FamilyMember {
    let name: String
    let imageName: String // Use "person.fill" or asset name
    let isMe: Bool // To distinguish the "Dad" vs others if needed
}
