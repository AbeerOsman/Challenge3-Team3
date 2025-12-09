import Foundation
import Combine
import FirebaseFirestore

// MARK: - ProfileViewModel
// يحفظ ويحمّل بيانات المستخدم على نفس الجهاز باستخدام UserDefaults + Firestore:
// - أول حفظ: إنشاء مستند جديد وتخزين docID محلياً + تخزين نسخة محلية من البيانات.
// - لاحقاً: تحديث نفس المستند فقط (بدون إنشاء مستند جديد) + تحديث النسخة المحلية.
// - عند العودة للتطبيق: تحميل النسخة المحلية فوراً، ثم محاولة تحديثها من Firestore إذا توفر docID.
// - الحذف: حذف نفس المستند وإزالة docID والنسخة المحلية وتفريغ الحقول.
@MainActor
final class ProfileViewModel: ObservableObject {
    // MARK: Published inputs (مدخلات الواجهة)
    @Published var name: String = ""
    @Published var selectedGender: Gender = .male
    @Published var ageText: String = ""                 // نص خام يُحوّل لاحقاً إلى Int
    @Published var selectedLevel: Level = .beginner
    @Published var selectedPlan: Plan = .free
    @Published var hourlyRateText: String = ""          // نص خام يُحوّل لاحقاً إلى Double
    @Published var selectedCareer: Career = .none       // NEW: المسار المهني

    // MARK: Published UI state (حالة الواجهة)
    @Published var isSaving: Bool = false               // لإظهار مؤشر التحميل أثناء الحفظ
    @Published var showSuccessAlert: Bool = false       // لعرض تنبيه النجاح
    @Published var errorMessage: String? = nil          // لعرض رسالة خطأ عند الحاجة
    @Published var lastActionIsDelete: Bool = false     // لتمييز نص التنبيه بين الحفظ/الحذف

    // MARK: Dependencies
    private let db = Firestore.firestore()
    private let defaults = UserDefaults.standard
    private let userDocIDKey = "userDocumentID"         // لتخزين معرف المستند
    private let userLocalProfileKey = "userLocalProfile"// لتخزين نسخة محلية من بيانات المستخدم

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
        // NEW: include career
        dict["career"] = selectedCareer.rawValue
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
            // NEW: load career
            if let c = dict["career"] as? String, let careerEnum = Career(rawValue: c) {
                self.selectedCareer = careerEnum
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
        self.selectedCareer = .none
    }

    // MARK: - Save (create or update same document using UserDefaults-stored docID) + cache locally
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
            // تحديث نفس المستند
            do {
                try await db.collection("users").document(docID).setData(dictToSave, merge: true)
                // تحديث النسخة المحلية أيضاً
                cacheLocalProfile(dictToSave)
                lastActionIsDelete = false
                showSuccessAlert = true
            } catch {
                errorMessage = "فشل تحديث البيانات: \(error.localizedDescription)"
                showSuccessAlert = false
            }
            isSaving = false
            return
        }

        // أول مرة: إنشاء مستند جديد ثم تخزين docID وتخزين نسخة محلية
        do {
            let ref = try await db.collection("users").addDocument(data: dictToSave)
            defaults.set(ref.documentID, forKey: userDocIDKey)
            cacheLocalProfile(dictToSave)
            lastActionIsDelete = false
            showSuccessAlert = true
        } catch {
            errorMessage = "حدث خطأ أثناء الحفظ: \(error.localizedDescription)"
            showSuccessAlert = false
        }
        isSaving = false
    }

    // MARK: - Load profile: show local cache first, then refresh from Firestore if possible
    func loadUserProfile() async {
        errorMessage = nil

        // أولاً: حمّل النسخة المحلية فوراً (تظهر مباشرة على الجهاز)
        loadLocalProfileIfAvailable()

        // ثانياً: إن وُجد docID، حاول التحديث من Firestore
        guard let docID = defaults.string(forKey: userDocIDKey), !docID.isEmpty else {
            return
        }

        do {
            let snapshot = try await db.collection("users").document(docID).getDocument()
            guard let data = snapshot.data() else { return }

            // عبِّئ الحقول من السحابة
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
            // NEW: load career from Firestore
            if let c = data["career"] as? String, let careerEnum = Career(rawValue: c) {
                self.selectedCareer = careerEnum
            }

            // بعد التحديث من السحابة، حدّث النسخة المحلية
            cacheLocalProfile(asDictionary)
        } catch {
            self.errorMessage = "فشل تحميل البيانات: \(error.localizedDescription)"
        }
    }

    // MARK: - Delete same document using stored docID + clear local cache
    func deleteUserProfile() async {
        errorMessage = nil
        showSuccessAlert = false

        guard let docID = defaults.string(forKey: userDocIDKey), !docID.isEmpty else {
            errorMessage = "لا يمكن الحذف: لا يوجد مستند محفوظ"
            return
        }

        do {
            try await db.collection("users").document(docID).delete()
            // إزالة المراجع المحلية
            defaults.removeObject(forKey: userDocIDKey)
            defaults.removeObject(forKey: userLocalProfileKey)
            // تفريغ الحقول محلياً (المسح من الكارد مباشرة)
            resetLocalFields()

            lastActionIsDelete = true
            showSuccessAlert = true
        } catch {
            errorMessage = "فشل حذف البيانات: \(error.localizedDescription)"
        }
    }
}

