import Foundation
import UIKit


// MARK: - TranslatorData (مُحسّن لدعم العرض بالعربية)
struct TranslatorData: Identifiable {
    let id: String
    let name: String
    let gender: String
    let age: String
    let level: String
    let price: String
    let category: String
    let career: String
    
    // خاصية محسوبة لتحديد الحالة: متطوع أو مدفوع
    var state: String {
        let cat = category.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let p = price.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // تقبل القيم سواء بالإنجليزية أو بالعربية
        let isVolunteerCategory = ["volunteer", "متطوع", "متطوعة", "تطوع"].contains { cat.contains($0) }
        let isPaidCategory = ["paid", "مدفوع", "مدفوعة"].contains { cat.contains($0) }
        
        if isVolunteerCategory || p == "0" || p.isEmpty {
            return "متطوع"
        } else if isPaidCategory {
            return "مدفوع"
        } else {
            // احتياطي: إذا السعر صفر أو فارغ اعتبر متطوع، وإلا اعتبر مدفوع
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
    let career: String   // المسار المهني للعرض في الواجهة
}

// MARK: - Translator level
enum TranslatorLevel: String {
    case beginner = "مبتدئ"
    case intermediate = "متوسط"
    case advanced = "متقدم"
    
    var display: String { rawValue }
}

// MARK: - حالة الموعد()
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
