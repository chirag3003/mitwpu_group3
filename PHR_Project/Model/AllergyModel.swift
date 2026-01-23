import Foundation


struct Allergy: Codable {
    var id: UUID?      // Local UUID (Legacy/Fallback)
    var apiID: String? // MongoDB ID
    var name: String
    var severity: String
    var notes: String?
    
    enum CodingKeys: String, CodingKey {
        case apiID = "_id"
        case name
        case severity
        case notes
        // 'id' is excluded from decoding/encoding automatically if not present in CodingKeys, 
        // but since we want to keep it property, we just omit it from keys so it's ignored by JSON decoder/encoder for API
    }
    
    // Custom init to handle local creation
    init(id: UUID? = nil, apiID: String? = nil, name: String, severity: String, notes: String?) {
        self.id = id
        self.apiID = apiID
        self.name = name
        self.severity = severity
        self.notes = notes
    }
    
    // Custom decoding to handle initialization of 'id'
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.apiID = try container.decodeIfPresent(String.self, forKey: .apiID)
        self.name = try container.decode(String.self, forKey: .name)
        self.severity = try container.decode(String.self, forKey: .severity)
        self.notes = try container.decodeIfPresent(String.self, forKey: .notes)
        self.id = UUID() // Generate a local UUID for UI consistency
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(apiID, forKey: .apiID)
        try container.encode(name, forKey: .name)
        try container.encode(severity, forKey: .severity)
        try container.encode(notes, forKey: .notes)
    }
}
