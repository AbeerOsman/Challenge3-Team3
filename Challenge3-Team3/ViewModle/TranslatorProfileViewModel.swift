import Foundation
import Combine
import FirebaseFirestore

// MARK: - TranslatorProfileViewModel
// مسؤول عن إدارة حالة شاشة "ملفي كمترجم":
// - حفظ بيانات المترجم في Firestore ضمن مجموعة "users".
// - التحقق من المدخلات (الاسم/العمر/الخطة والسعر).
// - دعم إدخال الأرقام العربية بتحويلها إلى صيغة رقمية صالحة.
@MainActor
final class TranslatorProfileViewModel: ObservableObject {
    // MARK: Published inputs (مدخلات الواجهة)
    @Published var name: String = ""
    @Published var selectedGender: Gender = .male
    @Published var ageText: String = ""                 // نص خام يُحوّل لاحقاً إلى Int
    @Published var selectedLevel: Level = .beginner
    @Published var selectedPlan: Plan = .free
    @Published var hourlyRateText: String = ""          // نص خام يُحوّل لاحقاً إلى Double
    @Published var selectedCareer: Career = .none      // المسار المهني (قانون، رعاية صحية، بدون، إلخ)

    // MARK: Published UI state (حالة الواجهة)
    @Published var isSaving: Bool = false               // لإظهار مؤشر التحميل أثناء الحفظ
    @Published var showSuccessAlert: Bool = false       // لعرض تنبيه النجاح
    @Published var errorMessage: String? = nil          // لعرض رسالة خطأ عند الحاجة

    // MARK: Dependencies
    private let db = Firestore.firestore()

    // MARK: - Arabic digits normalization
    // تحويل الأرقام العربية إلى إنجليزية + استبدال الفاصلة العربية/فاصل الآلاف
    // الهدف: السماح بإدخال أرقام عربية بشكل طبيعي ثم تحويلها لقيم رقمية صالحة.
    private func normalizeArabicDigits(in text: String) -> String {
        var result = text

        // تحويل الأرقام العربية إلى اللاتينية
        let arabicToLatinDigits: [Character: Character] = [
            "٠": "0", "١": "1", "٢": "2", "٣": "3", "٤": "4",
            "٥": "5", "٦": "6", "٧": "7", "٨": "8", "٩": "9"
        ]
        result = String(result.map { arabicToLatinDigits[$0] ?? $0 })

        // إزالة فاصل الآلاف العربي إن وجد
        result = result.replacingOccurrences(of: "٬", with: "")
        // استبدال الفاصلة العربية بفاصلة عشرية إنجليزية
        result = result.replacingOccurrences(of: "،", with: ".")
        // دعم إدخال فاصلة لاتينية كعشرية أيضاً
        result = result.replacingOccurrences(of: ",", with: ".")

        return result
    }

    // MARK: - Parsing helpers
    // تحويل ageText إلى Int بعد التطبيع.
    private func parseAge() -> Int? {
        let normalized = normalizeArabicDigits(in: ageText.trimmingCharacters(in: .whitespacesAndNewlines))
        return Int(normalized)
    }

    // تحويل hourlyRateText إلى Double بعد التطبيع.
    private func parseHourlyRate() -> Double? {
        let normalized = normalizeArabicDigits(in: hourlyRateText.trimmingCharacters(in: .whitespacesAndNewlines))
        return Double(normalized)
    }

    // MARK: - Validation
    // التحقق من صحة المدخلات قبل الحفظ.
    private func validateInputs() -> String? {
        // الاسم مطلوب
        if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "الاسم مطلوب"
        }
        // الحد الأدنى للعمر 18
        guard let age = parseAge(), age >= 18 else {
            return "الرجاء إدخال عمر صحيح (الحد الأدنى 18)"
        }
        // السعر مطلوب فقط إذا كانت الخطة مدفوعة
        if selectedPlan == .paid {
            guard let rate = parseHourlyRate(), rate >= 0 else {
                return "الرجاء إدخال سعر بالساعة صحيح"
            }
        }
        return nil
    }

    // MARK: - Save to Firestore
    // يحفظ نموذج UserProfile في مجموعة "users".
    func saveUserProfile() async {
        // تحقق أولي من المدخلات
        if let validationError = validateInputs() {
            errorMessage = validationError
            showSuccessAlert = false
            return
        }

        // تأكيد التحويلات الرقمية
        guard let age = parseAge(), age >= 18 else {
            errorMessage = "تحويل القيم الرقمية فشل"
            showSuccessAlert = false
            return
        }

        // إذا الخطة مجانية: السعر = 0
        let rate: Double = (selectedPlan == .free) ? 0 : (parseHourlyRate() ?? 0)

        isSaving = true
        errorMessage = nil

        // تجهيز نموذج التخزين
        let profile = UserProfile(
            id: UUID().uuidString,                                  // يمكن Firestore توليد ID أيضاً، لا مشكلة بتمرير UUID هنا
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            gender: selectedGender,
            age: age,
            level: selectedLevel,
            plan: selectedPlan,
            hourlyRate: rate,
            career: selectedCareer
        )

        // استخدام addDocument(data:) بأسلوب الإكمال (completion) لضمان التوافق
        db.collection("users").addDocument(data: profile.asDictionary) { [weak self] error in
            guard let self = self else { return }
            Task { @MainActor in
                if let error = error {
                    // فشل الحفظ
                    self.errorMessage = "حدث خطأ أثناء الحفظ: \(error.localizedDescription)"
                    self.showSuccessAlert = false
                } else {
                    // نجاح الحفظ
                    self.showSuccessAlert = true
                }
                self.isSaving = false
            }
        }
    }
}
