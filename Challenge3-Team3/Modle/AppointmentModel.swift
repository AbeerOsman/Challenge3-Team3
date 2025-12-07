import Foundation
import FirebaseFirestore

struct AppointmentRequest: Identifiable, Codable {
    @DocumentID var id: String?
    let deafUserId: String
    let deafName: String
    let translatorId: String  // ✨ Only store the ID
    let createdAt: Date
    
    init(deafUserId: String, deafName: String, translatorId: String) {
        self.deafUserId = deafUserId
        self.deafName = deafName
        self.translatorId = translatorId
        self.createdAt = Date()
    }
}

// ✨ New wrapper to hold appointment + real-time translator data
struct AppointmentWithTranslator: Identifiable {
    var id: String { appointment.id ?? "" }
    let appointment: AppointmentRequest
    let translator: TranslatorData?  // Fetched in real-time
}
