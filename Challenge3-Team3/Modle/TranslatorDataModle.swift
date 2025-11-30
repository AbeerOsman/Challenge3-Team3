import Foundation
import UIKit

// Updated TranslatorData with Firebase fields
struct TranslatorData: Identifiable {
    let id: String
    let name: String
    let gender: String
    let age: String
    let level: String
    let price: String
    let category: String
    
    // Computed property to determine state (volunteer or paid)
    var state: String {
        // Check if category/plan indicates volunteer
        if category == "متطوع" || price == "0" || price.isEmpty {
            return "متطوع"
        } else {
            return "مدفوع"
        }
    }
}

// Keep these for other parts of your app
struct Translator: Identifiable {
    let id = UUID()
    let name: String
    let priceRange: String
    let level: TranslatorLevel
    let experience: String
    let rating: Double
    let tags: [String]
    var isAvailable: Bool
}

enum TranslatorLevel: String {
    case beginner = "مبتدئ"
    case intermediate = "متوسط"
    case advanced = "متقدم"
}

enum AppointmentStatus {
    case pending
    case completed
    case paid
}

struct Appointment: Identifiable {
    let id = UUID()
    let translator: Translator
    let status: AppointmentStatus
}
