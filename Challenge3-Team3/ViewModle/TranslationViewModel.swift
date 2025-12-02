import Foundation
import Combine

class TranslationViewModel: ObservableObject {
    @Published var selectedLevel: TranslatorLevel? = nil
    @Published var translators: [TranslatorData] = []
    @Published var appointments: [AppointmentRequest] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Store deaf user info
    var deafUserId: String = ""
    var deafName: String = ""
    
    init() {
        print("🎬 TranslationViewModel initialized")
        fetchTranslators() // ✅ Fetch translators immediately
    }
    
    // Set deaf user info and fetch their appointments
    func setDeafUser(userId: String, name: String) {
        print("👤 Setting deaf user: \(name) (ID: \(userId))")
        self.deafUserId = userId
        self.deafName = name
        fetchUserAppointments()
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
    
    // Fetch user's appointments from Firebase
    func fetchUserAppointments() {
        guard !deafUserId.isEmpty else {
            print("⚠️ No user ID set - skipping appointment fetch")
            return
        }
        
        print("📥 Fetching appointments for user: \(deafUserId)")
        
        FirebaseService.shared.fetchUserAppointments(userId: deafUserId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let appointments):
                    print("✅ Loaded \(appointments.count) appointments")
                    self?.appointments = appointments
                case .failure(let error):
                    print("❌ Error loading appointments: \(error.localizedDescription)")
                    // Don't show error for appointments - it's optional
                }
            }
        }
    }
    
    // Request appointment - saves to Firebase
    func requestAppointment(for translator: TranslatorData, completion: @escaping (Bool) -> Void) {
        print("📝 Request appointment called")
        print("   Translator: \(translator.name)")
        print("   User ID: \(deafUserId)")
        print("   User Name: \(deafName)")
        
        guard !deafUserId.isEmpty else {
            print("❌ No user ID set")
            errorMessage = "User not logged in"
            completion(false)
            return
        }
        
        guard !deafName.isEmpty else {
            print("❌ No user name set")
            errorMessage = "User name is missing"
            completion(false)
            return
        }
        
        // Check if already exists
        if appointments.contains(where: { $0.translatorId == translator.id }) {
            print("⚠️ Appointment already exists")
            errorMessage = "You already have a request with this translator"
            completion(false)
            return
        }
        
        print("📤 Sending appointment to Firebase...")
        
        FirebaseService.shared.createAppointment(
            deafUserId: deafUserId,
            deafName: deafName,
            translator: translator
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("✅ Appointment created successfully")
                    self?.errorMessage = nil
                    completion(true)
                    
                case .failure(let error):
                    print("❌ Error creating appointment: \(error.localizedDescription)")
                    self?.errorMessage = "Failed to create appointment: \(error.localizedDescription)"
                    completion(false)
                }
            }
        }
    }
    
    // Cancel appointment - deletes from Firebase
    func cancelAppointment(appointmentId: String) {
        print("❌ Canceling appointment: \(appointmentId)")
        
        FirebaseService.shared.deleteAppointment(appointmentId: appointmentId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("✅ Appointment canceled")
                    self?.errorMessage = nil
                    
                case .failure(let error):
                    print("❌ Error canceling: \(error.localizedDescription)")
                    self?.errorMessage = "Failed to cancel appointment"
                }
            }
        }
    }
    
    // Get limited translators for home view (only 3)
    var limitedTranslators: [TranslatorData] {
        Array(translators.prefix(3))
    }
}
