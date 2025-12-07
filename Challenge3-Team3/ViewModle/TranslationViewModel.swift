import Foundation
import Combine

class TranslationViewModel: ObservableObject {
    @Published var selectedLevel: TranslatorLevel? = nil
    @Published var allTranslators: [TranslatorData] = [] {
        didSet { matchAppointmentsWithTranslators() }
    }

    @Published var translators: [TranslatorData] = []   // used ONLY for displaying/filtering
    @Published var appointments: [AppointmentRequest] = []
    @Published var appointmentsWithTranslators: [AppointmentWithTranslator] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    var deafUserId: String = ""
    var deafName: String = ""
    
    init() {
        print("🎬 TranslationViewModel initialized")
        fetchTranslators()
    }
    
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
                // unwrap weak self once and use `self` safely below
                guard let self = self else { return }

                print("📲 Returning to main thread")
                self.isLoading = false

                switch result {
                case .success(let translators):
                    print("✅ SUCCESS: Received \(translators.count) translators")
                    // store full list in allTranslators (triggers didSet -> rematch)
                    self.allTranslators = translators

                    // if user hasn't applied any filter, keep UI list in sync
                    if self.selectedLevel == nil {
                        self.translators = translators
                    } else if let level = self.selectedLevel {
                        // if a level filter is already active, apply it locally
                        self.translators = translators.filter { $0.level == level.rawValue }
                    }

                case .failure(let error):
                    print("❌ FAILURE: \(error.localizedDescription)")
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }

    
    func filterByLevel(_ level: TranslatorLevel) {
        print("🔍 Filtering by level: \(level.rawValue)")
        selectedLevel = level
        isLoading = false
        errorMessage = nil
        
        // ✨ FIXED: Filter from allTranslators (the full unfiltered list)
        translators = allTranslators.filter { $0.level == level.rawValue }
        
        print("✅ Filtered locally: Found \(translators.count) translators with level: \(level.rawValue)")
    }
    
    func clearFilter() {
        print("🔄 Clearing filter")
        selectedLevel = nil
        translators = allTranslators
    }

    
    func fetchUserAppointments() {
        guard !deafUserId.isEmpty else {
            print("⚠️ No user ID set - skipping appointment fetch")
            return
        }
        
        print("📥 Setting up appointments listener for user: \(deafUserId)")
        
        FirebaseService.shared.fetchUserAppointments(userId: deafUserId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let appointments):
                    print("✅ Appointments listener fired! Received \(appointments.count) appointments")
                    self?.appointments = appointments
                    self?.matchAppointmentsWithTranslators()  // ✨ Match with translators
                    
                case .failure(let error):
                    print("❌ Error loading appointments: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // ✨ NEW: Match appointments with current translator data
    private func matchAppointmentsWithTranslators() {
        print("🔗 Matching appointments with translators...")
        print("   Total appointments: \(appointments.count)")
        print("   Total allTranslators: \(allTranslators.count)")

        // Use the master unfiltered list `allTranslators` for matching
        appointmentsWithTranslators = appointments.map { appointment in
            // NOTE: correct property name is `translatorId` (camelCase)
            let translator = allTranslators.first { $0.id == appointment.translatorId }

            if translator != nil {
                print("✅ Found translator: \(translator!.name) for appointment")
            } else {
                print("⚠️ No translator found for ID: \(appointment.translatorId)")
            }

            return AppointmentWithTranslator(
                appointment: appointment,
                translator: translator
            )
        }

        print("✅ Created \(appointmentsWithTranslators.count) matched appointments")
    }
    
    // ✨ Public method to force re-match (called after Firebase updates)
    func forceRematchAppointments() {
        print("🔄 Force re-matching appointments...")
        matchAppointmentsWithTranslators()
    }


    
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
            translatorId: translator.id  // ✨ Only pass ID
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("✅ Appointment created successfully")
                    self?.errorMessage = nil
                    
                    // ✨ CRITICAL: Refresh translator data and force re-match
                    print("🔄 Refreshing translator data...")
                    self?.fetchTranslators()
                    
                    // ✨ Also force re-match after a small delay to ensure data is loaded
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        print("🔄 Force re-matching appointments...")
                        self?.forceRematchAppointments()
                    }
                    
                    completion(true)
                    
                case .failure(let error):
                    print("❌ Error creating appointment: \(error.localizedDescription)")
                    self?.errorMessage = "Failed to create appointment: \(error.localizedDescription)"
                    completion(false)
                }
            }
        }
    }
    
    func cancelAppointment(appointmentId: String) {
        print("❌ Canceling appointment: \(appointmentId)")
        
        FirebaseService.shared.deleteAppointment(appointmentId: appointmentId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("✅ Appointment canceled successfully")
                    self?.errorMessage = nil
                    
                    // ✨ Refresh translator data and force re-match
                    print("🔄 Refreshing translator data after cancellation...")
                    self?.fetchTranslators()
                    
                    // ✨ Force re-match after a small delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        print("🔄 Force re-matching appointments after cancellation...")
                        self?.forceRematchAppointments()
                    }
                    
                case .failure(let error):
                    print("❌ Error canceling: \(error.localizedDescription)")
                    self?.errorMessage = "Failed to cancel appointment: \(error.localizedDescription)"
                }
            }
        }
    }
    
    // ✨ FIXED: Show latest 3 translators from allTranslators (unfiltered)
    // This is used in DeafHome "Available Translators" section
    // It will ALWAYS show the latest added translators regardless of level filter
    var limitedTranslators: [TranslatorData] {
        Array(allTranslators.prefix(3))
    }
}
