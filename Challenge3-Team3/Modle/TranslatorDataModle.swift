import Foundation
import UIKit

// MARK: - TranslatorData (updated to support multiple careers + Firebase UID)
struct TranslatorData: Identifiable, Codable, Equatable {
    let id: String  // This is the Firestore document ID
    let firebaseUID: String  // ✅ NEW: Firebase Auth UID
    let name: String
    let gender: String
    let age: String
    let level: String
    let price: String
    let category: String
    let career: String   // Display string (joined from careers array)
    let careers: [String]  // array of careers from Firebase
    
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
