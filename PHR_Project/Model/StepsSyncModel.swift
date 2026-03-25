import Foundation

struct StepData: Codable {
    let dateRecorded: Date
    let stepCount: Int
    let source: String
}

struct StepSyncRequest: Codable {
    let steps: [StepData]
}

struct LastSyncResponse: Codable {
    let lastSyncDate: Date?
    let nextSyncStartDate: Date?
}

struct StepSyncResult: Codable {
    let success: Bool
    let synced: Int
}
