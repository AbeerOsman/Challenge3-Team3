import Foundation
import FirebaseFirestore

enum Gender: String, CaseIterable, Identifiable, Codable {
    case male = "ذكر"
    case female = "أنثى"
    var id: String { rawValue }
}

enum Level: String, CaseIterable, Identifiable, Codable {
    case beginner = "مبتدئ"
    case intermediate = "متوسط"
    case advanced = "متقدم"
    var id: String { rawValue }
}

enum Plan: String, CaseIterable, Identifiable, Codable {
    case free = "متطوع"
    case paid = "مدفوع"
    var id: String { rawValue }
}

// شوية مساعدات لتطبيع النص العربي عشان المطابقة تكون أسهل
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

// تفكيك وترميز مرن للأنواع عشان نقبل صيغ مختلفة
extension Gender {
    init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        if let raw = try? c.decode(String.self) {
            let t = raw.trimmingCharacters(in: .whitespacesAndNewlines)
            if matchArabic(t, candidates: [Gender.male.rawValue]) { self = .male; return }
            if matchArabic(t, candidates: [Gender.female.rawValue]) { self = .female; return }
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
            if matchArabic(t, candidates: [Level.beginner.rawValue]) { self = .beginner; return }
            if matchArabic(t, candidates: [Level.intermediate.rawValue]) { self = .intermediate; return }
            if matchArabic(t, candidates: [Level.advanced.rawValue]) { self = .advanced; return }
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
            if matchArabic(t, candidates: [Plan.free.rawValue, "متطوعه", "تطوع", "متطوع"]) { self = .free; return }
            if matchArabic(t, candidates: [Plan.paid.rawValue]) { self = .paid; return }
            switch t.lowercased() {
            case "free", "volunteer", "mutatawi", "mutataweh", "0": self = .free
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

// نموذج المستخدم
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
