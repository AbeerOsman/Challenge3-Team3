import Foundation
import FirebaseFirestore

struct AppointmentRequest: Identifiable, Codable {
    @DocumentID var id: String?
    let deafUserId: String
    let deafName: String
    let translatorId: String
    let translatorName: String
    let translatorGender: String
    let translatorAge: String
    let translatorLevel: String
    let translatorPrice: String
    let translatorCategory: String
    let createdAt: Date
    
    init(deafUserId: String, deafName: String, translator: TranslatorData) {
        self.deafUserId = deafUserId
        self.deafName = deafName
        self.translatorId = translator.id
        self.translatorName = translator.name
        self.translatorGender = translator.gender
        self.translatorAge = translator.age
        self.translatorLevel = translator.level
        self.translatorPrice = translator.price
        self.translatorCategory = translator.category
        self.createdAt = Date()
    }
}
