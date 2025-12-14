import Foundation
import FirebaseFirestore

struct AppointmentRequest: Identifiable, Codable {
    @DocumentID var id: String?
    let deafUserId: String
    let deafName: String
    let translatorId: String
    var createdAt: Date?  // ✅ Make optional to handle missing/null values
    
    init(deafUserId: String, deafName: String, translatorId: String) {
        self.deafUserId = deafUserId
        self.deafName = deafName
        self.translatorId = translatorId
        self.createdAt = Date()
    }
    
    enum CodingKeys: String, CodingKey {
        case deafUserId
        case deafName
        case translatorId
        case createdAt
    }
    
    // Custom decoding to handle Timestamp safely
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        deafUserId = try container.decode(String.self, forKey: .deafUserId)
        deafName = try container.decode(String.self, forKey: .deafName)
        translatorId = try container.decode(String.self, forKey: .translatorId)
        
        // Safely decode createdAt - it might be a Timestamp or Date
        if let timestamp = try container.decodeIfPresent(Timestamp.self, forKey: .createdAt) {
            createdAt = timestamp.dateValue()
        } else if let date = try container.decodeIfPresent(Date.self, forKey: .createdAt) {
            createdAt = date
        } else {
            createdAt = Date()  // Default to now if missing
        }
    }
    
    // Custom encoding
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(deafUserId, forKey: .deafUserId)
        try container.encode(deafName, forKey: .deafName)
        try container.encode(translatorId, forKey: .translatorId)
        if let createdAt = createdAt {
            try container.encode(Timestamp(date: createdAt), forKey: .createdAt)
        }
    }
}

// ✨ Wrapper to hold appointment + real-time translator data
struct AppointmentWithTranslator: Identifiable {
    var id: String { appointment.id ?? "" }
    let appointment: AppointmentRequest
    let translator: TranslatorData?
}
