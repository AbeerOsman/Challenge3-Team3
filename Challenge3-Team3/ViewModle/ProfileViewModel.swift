// ⚠️ DELETE THE OLD TranslatorProfileViewModel FILE
//
// REPLACEMENT INSTRUCTIONS:
// 1. Delete the old "TranslatorProfileViewModel.swift" file from your project
// 2. Use the "ProfileViewModel" instead (it has the same functionality + multi-career support)
// 3. Replace all occurrences of @StateObject private var viewModel = TranslatorProfileViewModel()
//    with: @StateObject private var viewModel = ProfileViewModel()
//
// Below is the complete ProfileViewModel that replaces the old one:

import Foundation
import Combine
import FirebaseFirestore

@MainActor
final class ProfileViewModel: ObservableObject {
    // MARK: Published inputs
    @Published var name: String = ""
    @Published var selectedGender: Gender = .male
    @Published var ageText: String = ""
    @Published var selectedLevel: Level = .beginner
    @Published var selectedPlan: Plan = .free
    @Published var hourlyRateText: String = ""
    @Published var selectedCareers: Set<Career> = []  

    // MARK: Published UI state
    @Published var isSaving: Bool = false
    @Published var showSuccessAlert: Bool = false
    @Published var errorMessage: String? = nil
    @Published var lastActionIsDelete: Bool = false

    // MARK: Dependencies
    private let db = Firestore.firestore()
    private let defaults = UserDefaults.standard
    private let userDocIDKey = "userDocumentID"
    private let userLocalProfileKey = "userLocalProfile"

    // MARK: - Arabic digits normalization
    private func normalizeArabicDigits(in text: String) -> String {
        var result = text
        let arabicToLatinDigits: [Character: Character] = [
            "٠": "0", "١": "1", "٢": "2", "٣": "3", "٤": "4",
            "٥": "5", "٦": "6", "٧": "7", "٨": "8", "٩": "9"
        ]
        result = String(result.map { arabicToLatinDigits[$0] ?? $0 })
        result = result.replacingOccurrences(of: "٬", with: "")
        result = result.replacingOccurrences(of: "،", with: ".")
        result = result.replacingOccurrences(of: ",", with: ".")
        return result
    }

    // MARK: - Parsing helpers
    private func parseAge() -> Int? {
        let normalized = normalizeArabicDigits(in: ageText.trimmingCharacters(in: .whitespacesAndNewlines))
        return Int(normalized)
    }

    private func parseHourlyRate() -> Double? {
        let normalized = normalizeArabicDigits(in: hourlyRateText.trimmingCharacters(in: .whitespacesAndNewlines))
        return Double(normalized)
    }

    // MARK: - Validation
    private func validateInputs() -> String? {
        if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "الاسم مطلوب"
        }
        guard let age = parseAge(), age >= 18 else {
            return "الرجاء إدخال عمر صحيح (الحد الأدنى 18)"
        }
        if selectedPlan == .paid {
            guard let rate = parseHourlyRate(), rate >= 0 else {
                return "الرجاء إدخال سعر بالساعة صحيح"
            }
        }
        return nil
    }

    // MARK: - Helper: build dictionary for Firestore
    private var asDictionary: [String: Any] {
        var dict: [String: Any] = [
            "name": name.trimmingCharacters(in: .whitespacesAndNewlines),
            "gender": selectedGender.rawValue,
            "age": parseAge() ?? 0,
            "level": selectedLevel.rawValue,
            "plan": selectedPlan.rawValue,
            "hourlyRate": (selectedPlan == .free) ? 0 : (parseHourlyRate() ?? 0)
        ]
        // ✅ Store all selected careers as array
        if !selectedCareers.isEmpty {
            dict["careers"] = selectedCareers.map { $0.rawValue }
        } else {
            dict["careers"] = []
        }
        return dict
    }

    // MARK: - Local cache helpers
    private func cacheLocalProfile(_ dict: [String: Any]) {
        defaults.set(dict, forKey: userLocalProfileKey)
    }

    private func loadLocalProfileIfAvailable() {
        if let dict = defaults.dictionary(forKey: userLocalProfileKey) {
            if let n = dict["name"] as? String { self.name = n }
            if let g = dict["gender"] as? String, let genderEnum = Gender(rawValue: g) {
                self.selectedGender = genderEnum
            }
            if let ageNumber = dict["age"] as? Int {
                self.ageText = "\(ageNumber)"
            } else if let ageString = dict["age"] as? String {
                self.ageText = ageString
            }
            if let lvl = dict["level"] as? String, let levelEnum = Level(rawValue: lvl) {
                self.selectedLevel = levelEnum
            }
            if let plan = dict["plan"] as? String, let planEnum = Plan(rawValue: plan) {
                self.selectedPlan = planEnum
            }
            if let rate = dict["hourlyRate"] as? Double {
                self.hourlyRateText = rate == 0 ? "" : "\(rate)"
            } else if let rateInt = dict["hourlyRate"] as? Int {
                self.hourlyRateText = rateInt == 0 ? "" : "\(rateInt)"
            }
            // ✅ Load multiple careers
            if let careersArray = dict["careers"] as? [String] {
                self.selectedCareers = Set(careersArray.compactMap { Career(rawValue: $0) })
            }
        }
    }

    private func resetLocalFields() {
        self.name = ""
        self.selectedGender = .male
        self.ageText = ""
        self.selectedLevel = .beginner
        self.selectedPlan = .free
        self.hourlyRateText = ""
        self.selectedCareers = []
    }

    // MARK: - Save
    func saveUserProfile() async {
        if let validationError = validateInputs() {
            errorMessage = validationError
            showSuccessAlert = false
            return
        }

        isSaving = true
        errorMessage = nil

        let dictToSave = asDictionary

        if let docID = defaults.string(forKey: userDocIDKey), !docID.isEmpty {
            // Update existing document
            do {
                try await db.collection("users").document(docID).setData(dictToSave, merge: true)
                cacheLocalProfile(dictToSave)
                lastActionIsDelete = false
                showSuccessAlert = true
                print("✅ Profile updated successfully: \(docID)")
            } catch {
                errorMessage = "فشل تحديث البيانات: \(error.localizedDescription)"
                showSuccessAlert = false
                print("❌ Error updating profile: \(error.localizedDescription)")
            }
            isSaving = false
            return
        }

        // Create new document
        do {
            let ref = try await db.collection("users").addDocument(data: dictToSave)
            defaults.set(ref.documentID, forKey: userDocIDKey)
            cacheLocalProfile(dictToSave)
            lastActionIsDelete = false
            showSuccessAlert = true
            print("✅ Profile saved successfully with ID: \(ref.documentID)")
        } catch {
            errorMessage = "حدث خطأ أثناء الحفظ: \(error.localizedDescription)"
            showSuccessAlert = false
            print("❌ Error saving profile: \(error.localizedDescription)")
        }
        isSaving = false
    }

    // MARK: - Load profile
    func loadUserProfile() async {
        errorMessage = nil
        loadLocalProfileIfAvailable()

        guard let docID = defaults.string(forKey: userDocIDKey), !docID.isEmpty else {
            print("ℹ️ No saved profile found")
            return
        }

        do {
            let snapshot = try await db.collection("users").document(docID).getDocument()
            guard let data = snapshot.data() else {
                print("⚠️ Snapshot has no data")
                return
            }

            if let n = data["name"] as? String { self.name = n }
            if let g = data["gender"] as? String, let genderEnum = Gender(rawValue: g) {
                self.selectedGender = genderEnum
            }
            if let ageNumber = data["age"] as? Int {
                self.ageText = "\(ageNumber)"
            } else if let ageString = data["age"] as? String {
                self.ageText = ageString
            }
            if let lvl = data["level"] as? String, let levelEnum = Level(rawValue: lvl) {
                self.selectedLevel = levelEnum
            }
            if let plan = data["plan"] as? String, let planEnum = Plan(rawValue: plan) {
                self.selectedPlan = planEnum
            }
            if let rate = data["hourlyRate"] as? Double {
                self.hourlyRateText = rate == 0 ? "" : "\(rate)"
            } else if let rateInt = data["hourlyRate"] as? Int {
                self.hourlyRateText = rateInt == 0 ? "" : "\(rateInt)"
            }
            // ✅ Load multiple careers from Firestore
            if let careersArray = data["careers"] as? [String] {
                self.selectedCareers = Set(careersArray.compactMap { Career(rawValue: $0) })
            }

            cacheLocalProfile(asDictionary)
            print("✅ Profile loaded from Firestore")
        } catch {
            self.errorMessage = "فشل تحميل البيانات: \(error.localizedDescription)"
            print("❌ Error loading profile: \(error.localizedDescription)")
        }
    }

    // MARK: - Delete
    func deleteUserProfile() async {
        errorMessage = nil
        showSuccessAlert = false

        guard let docID = defaults.string(forKey: userDocIDKey), !docID.isEmpty else {
            errorMessage = "لا يمكن الحذف: لا يوجد مستند محفوظ"
            return
        }

        do {
            try await db.collection("users").document(docID).delete()
            defaults.removeObject(forKey: userDocIDKey)
            defaults.removeObject(forKey: userLocalProfileKey)
            resetLocalFields()

            lastActionIsDelete = true
            showSuccessAlert = true
            print("✅ Profile deleted successfully")
        } catch {
            errorMessage = "فشل حذف البيانات: \(error.localizedDescription)"
            print("❌ Error deleting profile: \(error.localizedDescription)")
        }
    }
}
