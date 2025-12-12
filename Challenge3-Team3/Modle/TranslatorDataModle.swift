import Foundation
import UIKit

// MARK: - TranslatorData (updated to support multiple careers)
struct TranslatorData: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let gender: String
    let age: String
    let level: String
    let price: String
    let category: String
    let career: String   // Display string (joined from careers array)
    let careers: [String]  // NEW: array of careers from Firebase
    
    // Computed property for display state
    var state: String {
        let cat = category.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let p = price.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let isVolunteerCategory = ["volunteer", "متطوع", "متطوعة", "تطوع"].contains { cat.contains($0) }
        let isPaidCategory = ["paid", "مدفوع", "مدفوعة"].contains { cat.contains($0) }
        
        if isVolunteerCategory || p == "0" || p.isEmpty {
            return "متطوع"
        } else if isPaidCategory {
            return "مدفوع"
        } else {
            if p == "0" || p.isEmpty {
                return "متطوع"
            } else {
                return "مدفوع"
            }
        }
    }
}

// MARK: - Translator model
struct Translator: Identifiable {
    let id = UUID()
    let name: String
    let priceRange: String
    let level: TranslatorLevel
    let experience: String
    let rating: Double
    let tags: [String]
    var isAvailable: Bool
    let career: String
}

// MARK: - Translator level
enum TranslatorLevel: String {
    case beginner = "مبتدئ"
    case intermediate = "متوسط"
    case advanced = "متقدم"
    
    var display: String { rawValue }
}

// MARK: - Appointment Status
enum AppointmentStatus {
    case pending
    case completed
    case paid
    
    var display: String {
        switch self {
        case .pending: return "قيد الانتظار"
        case .completed: return "مكتمل"
        case .paid: return "مدفوع"
        }
    }
}

// MARK: - Appointment model
struct Appointment: Identifiable {
    let id = UUID()
    let translator: Translator
    let status: AppointmentStatus
}
