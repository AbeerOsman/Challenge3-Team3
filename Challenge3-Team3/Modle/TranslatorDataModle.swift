import Foundation
import UIKit

// Updated TranslatorData with Firebase fields (English)
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
        if category == "Volunteer" || price == "0" || price.isEmpty {
            return "Volunteer"
        } else {
            return "Paid"
        }
    }
}

// Keep these for other parts of your app — translated to English
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
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
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
