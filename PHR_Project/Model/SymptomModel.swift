import Foundation

struct Symptom: Codable {
    var id: UUID?
    var apiID: String?
    var symptomName: String
    var intensity: String
    var dateRecorded: Foundation.Date
    var notes: String?
    var time: DateComponents

    enum CodingKeys: String, CodingKey {
        case apiID = "_id"
        case symptomName
        case intensity
        case dateRecorded
        case notes
        case time
    }

    struct TimeData: Codable {
        let hour: Int
        let minute: Int
    }

    // Custom init to handle local creation
    init(
        id: UUID? = nil,
        apiID: String? = nil,
        symptomName: String,
        intensity: String,
        dateRecorded: Date,
        notes: String?,
        time: DateComponents
    ) {
        self.id = id
        self.apiID = apiID
        self.symptomName = symptomName
        self.intensity = intensity
        self.dateRecorded = dateRecorded
        self.notes = notes
        self.time = time
    }

    // Custom decoding
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.apiID = try container.decodeIfPresent(String.self, forKey: .apiID)
        self.symptomName = try container.decode(
            String.self,
            forKey: .symptomName
        )
        self.intensity = try container.decode(String.self, forKey: .intensity)
        self.dateRecorded = try container.decode(
            Date.self,
            forKey: .dateRecorded
        )
        self.notes = try container.decodeIfPresent(String.self, forKey: .notes)

        let timeData = try container.decode(TimeData.self, forKey: .time)
        var components = DateComponents()
        components.hour = timeData.hour
        components.minute = timeData.minute
        self.time = components

        self.id = UUID()  // Generate a local UUID for UI consistency
    }

    // Custom encoding
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(apiID, forKey: .apiID)
        try container.encode(symptomName, forKey: .symptomName)
        try container.encode(intensity, forKey: .intensity)
        try container.encode(dateRecorded, forKey: .dateRecorded)
        try container.encode(notes, forKey: .notes)

        let timeData = TimeData(hour: time.hour ?? 0, minute: time.minute ?? 0)
        try container.encode(timeData, forKey: .time)
    }
}

struct Symptoms {
    var allSymptoms: [Symptom]
}
