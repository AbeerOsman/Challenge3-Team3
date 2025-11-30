import Foundation
import Combine

class TranslationViewModel: ObservableObject {
    @Published var selectedLevel: TranslatorLevel? = nil
    @Published var translators: [TranslatorData] = []
    @Published var appointments: [TranslatorData] = [] // NEW: Track appointments
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    init() {
        print("🎬 TranslationViewModel initialized")
        fetchTranslators()
    }
    
    func fetchTranslators() {
        print("🚀 fetchTranslators() called")
        isLoading = true
        errorMessage = nil
        
        FirebaseService.shared.fetchTranslators { [weak self] result in
            DispatchQueue.main.async {
                print("📲 Returning to main thread")
                self?.isLoading = false
                
                switch result {
                case .success(let translators):
                    print("✅ SUCCESS: Received \(translators.count) translators")
                    self?.translators = translators
                    
                case .failure(let error):
                    print("❌ FAILURE: \(error.localizedDescription)")
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func filterByLevel(_ level: TranslatorLevel) {
        print("🔍 Filtering by level: \(level.rawValue)")
        selectedLevel = level
        isLoading = true
        errorMessage = nil
        
        FirebaseService.shared.fetchTranslatorsByLevel(level: level.rawValue) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let translators):
                    print("✅ Filtered: Found \(translators.count) translators")
                    self?.translators = translators
                case .failure(let error):
                    print("❌ Filter error: \(error.localizedDescription)")
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func clearFilter() {
        print("🔄 Clearing filter")
        selectedLevel = nil
        fetchTranslators()
    }
    
    // NEW: Add appointment request
    func requestAppointment(for translator: TranslatorData) {
        print("📝 Requesting appointment for: \(translator.name)")
        // Check if already exists
        if !appointments.contains(where: { $0.id == translator.id }) {
            appointments.append(translator)
            print("✅ Appointment added. Total appointments: \(appointments.count)")
        } else {
            print("⚠️ Appointment already exists for this translator")
        }
    }
    
    // NEW: Remove appointment
    func cancelAppointment(for translator: TranslatorData) {
        print("❌ Canceling appointment for: \(translator.name)")
        appointments.removeAll(where: { $0.id == translator.id })
        print("✅ Appointment removed. Total appointments: \(appointments.count)")
    }
    
    // NEW: Get limited translators for home view (only 3)
    var limitedTranslators: [TranslatorData] {
        Array(translators.prefix(3))
    }
}
