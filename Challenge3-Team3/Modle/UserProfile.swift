import Foundation
import FirebaseFirestore

enum Gender: String, CaseIterable, Identifiable, Codable {
    case male = "Male"
    case female = "Female"
    var id: String { rawValue }
}

enum Level: String, CaseIterable, Identifiable, Codable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
    var id: String { rawValue }
}

enum Plan: String, CaseIterable, Identifiable, Codable {
    case free = "Volunteer"
    case paid = "Paid"
    var id: String { rawValue }
}

// Arabic normalization helpers (kept same logic)
private extension String {
    var trimmedLowercased: String {
        trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    func normalizeArabic() -> String {
        var s = self
        let diacritics: [Character] = [
            "\u{064B}", "\u{064C}", "\u{064D}",
            "\u{064E}", "\u{064F}", "\u{0650}",
            "\u{0651}", "\u{0652}"
        ]
        s.removeAll(where: { diacritics.contains($0) })
        s = s.replacingOccurrences(of: "أ", with: "ا")
        s = s.replacingOccurrences(of: "إ", with: "ا")
        s = s.replacingOccurrences(of: "آ", with: "ا")
        s = s.replacingOccurrences(of: "ة", with: "ه")
        s = s.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        return s.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

private func matchArabic(_ raw: String, candidates: [String]) -> Bool {
    let n = raw.normalizeArabic()
    return candidates.map { $0.normalizeArabic() }.contains(n)
}

// Flexible decoding/encoding
extension Gender {
    init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        if let raw = try? c.decode(String.self) {
            let t = raw.trimmingCharacters(in: .whitespacesAndNewlines)
            if matchArabic(t, candidates: ["ذكر", "Male"]) { self = .male; return }
            if matchArabic(t, candidates: ["أنثى", "Female"]) { self = .female; return }
            switch t.lowercased() {
            case "male", "m": self = .male
            case "female", "f": self = .female
            default:
                throw DecodingError.dataCorruptedError(in: c, debugDescription: "Unknown gender: \(raw)")
            }
            return
        }
        if let num = try? c.decode(Int.self) {
            switch num {
            case 0: self = .male
            case 1: self = .female
            default:
                throw DecodingError.dataCorruptedError(in: c, debugDescription: "Unknown gender int: \(num)")
            }
            return
        }
        throw DecodingError.dataCorruptedError(in: c, debugDescription: "Unsupported gender type")
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.singleValueContainer()
        try c.encode(rawValue)
    }
}

extension Level {
    init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        if let raw = try? c.decode(String.self) {
            let t = raw.trimmingCharacters(in: .whitespacesAndNewlines)
            if matchArabic(t, candidates: ["مبتدئ", "Beginner"]) { self = .beginner; return }
            if matchArabic(t, candidates: ["متوسط", "Intermediate"]) { self = .intermediate; return }
            if matchArabic(t, candidates: ["متقدم", "Advanced"]) { self = .advanced; return }
            switch t.lowercased() {
            case "beginner", "beg", "b", "0": self = .beginner
            case "intermediate", "mid", "i", "1": self = .intermediate
            case "advanced", "adv", "a", "2": self = .advanced
            default:
                throw DecodingError.dataCorruptedError(in: c, debugDescription: "Unknown level: \(raw)")
            }
            return
        }
        if let num = try? c.decode(Int.self) {
            switch num {
            case 0: self = .beginner
            case 1: self = .intermediate
            case 2: self = .advanced
            default:
                throw DecodingError.dataCorruptedError(in: c, debugDescription: "Unknown level int: \(num)")
            }
            return
        }
        throw DecodingError.dataCorruptedError(in: c, debugDescription: "Unsupported level type")
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.singleValueContainer()
        try c.encode(rawValue)
    }
}

extension Plan {
    init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        if let raw = try? c.decode(String.self) {
            let t = raw.trimmingCharacters(in: .whitespacesAndNewlines)
            if matchArabic(t, candidates: ["متطوع", "متطوعه", "تطوع", "Volunteer"]) {
                self = .free; return
            }
            if matchArabic(t, candidates: ["مدفوع", "Paid"]) {
                self = .paid; return
            }
            switch t.lowercased() {
            case "free", "volunteer", "0": self = .free
            case "paid", "1": self = .paid
            default:
                throw DecodingError.dataCorruptedError(in: c, debugDescription: "Unknown plan: \(raw)")
            }
            return
        }
        if let num = try? c.decode(Int.self) {
            switch num {
            case 0: self = .free
            case 1: self = .paid
            default:
                throw DecodingError.dataCorruptedError(in: c, debugDescription: "Unknown plan int: \(num)")
            }
            return
        }
        throw DecodingError.dataCorruptedError(in: c, debugDescription: "Unsupported plan type")
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.singleValueContainer()
        try c.encode(rawValue)
    }
}

// User model
struct UserProfile: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var gender: Gender
    var age: Int
    var level: Level
    var plan: Plan
    var hourlyRate: Double

    var asDictionary: [String: Any] {
        [
            "name": name,
            "gender": gender.rawValue,
            "age": age,
            "level": level.rawValue,
            "plan": plan.rawValue,
            "hourlyRate": hourlyRate
        ]
    }
}
