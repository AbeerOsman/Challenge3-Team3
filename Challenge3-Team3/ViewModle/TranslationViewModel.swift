import Foundation
import Combine

// MARK: - Conversation Model
struct Conversation: Identifiable {
    let id: String
    let translatorId: String
    let translatorName: String
    let lastMessage: String
    let timestamp: Date
    
    init(translatorId: String,
         translatorName: String,
         lastMessage: String = "تم إنشاء المحادثة",
         timestamp: Date = Date()) {
        self.id = UUID().uuidString
        self.translatorId = translatorId
        self.translatorName = translatorName
        self.lastMessage = lastMessage
        self.timestamp = timestamp
    }
}

// MARK: - Translation ViewModel
class TranslationViewModel: ObservableObject {
    @Published var openChatWith: TranslatorData? = nil
    @Published var selectedLevel: TranslatorLevel? = nil
    @Published var allTranslators: [TranslatorData] = [] {
        didSet { matchAppointmentsWithTranslators() }
    }
    @Published var translators: [TranslatorData] = []   // For displaying/filtering
    @Published var appointments: [AppointmentRequest] = []
    @Published var appointmentsWithTranslators: [AppointmentWithTranslator] = []
    @Published var conversations: [Conversation] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    var deafUserId: String = ""
    var deafName: String = ""
    
//    init() {
//        print("🎬 TranslationViewModel initialized")
//        fetchTranslators()
//    }
    
    // MARK: - Set current deaf user
    func setDeafUser(userId: String, name: String) {
        print("👤 Setting deaf user: \(name) (ID: \(userId))")
        self.deafUserId = userId
        self.deafName = name
        fetchUserAppointments()
    }
    
    // MARK: - Fetch Translators
    func fetchTranslators() {
        print("🚀 fetchTranslators() called")
        isLoading = true
        errorMessage = nil
        
        FirebaseService.shared.fetchTranslators { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false
                
                switch result {
                case .success(let translators):
                    print("✅ Received \(translators.count) translators")
                    self.allTranslators = translators
                    if self.selectedLevel == nil {
                        self.translators = translators
                    } else if let level = self.selectedLevel {
                        self.translators = translators.filter { $0.level == level.rawValue }
                    }
                    
                case .failure(let error):
                    print("❌ Failure: \(error.localizedDescription)")
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    // MARK: - Filter by level
    func filterByLevel(_ level: TranslatorLevel) {
        print("🔍 Filtering by level: \(level.rawValue)")
        selectedLevel = level
        translators = allTranslators.filter { $0.level == level.rawValue }
    }
    
    func clearFilter() {
        selectedLevel = nil
        translators = allTranslators
    }
    
    // MARK: - Fetch appointments
    func fetchUserAppointments() {
        guard !deafUserId.isEmpty else { return }
        
        FirebaseService.shared.fetchUserAppointments(userId: deafUserId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let appointments):
                    self?.appointments = appointments
                    self?.matchAppointmentsWithTranslators()
                case .failure(let error):
                    print("❌ Error loading appointments: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Match appointments with translators
    private func matchAppointmentsWithTranslators() {
        appointmentsWithTranslators = appointments.map { appointment in
            let translator = allTranslators.first { $0.id == appointment.translatorId }
            return AppointmentWithTranslator(appointment: appointment, translator: translator)
        }
    }
    
    func forceRematchAppointments() {
        matchAppointmentsWithTranslators()
    }
    
    // MARK: - Request Appointment & Create Conversation
    func requestAppointment(for translator: TranslatorData, completion: @escaping (Bool) -> Void) {
        guard !deafUserId.isEmpty else {
            errorMessage = "User not logged in"
            completion(false)
            return
        }
        
        if appointments.contains(where: { $0.translatorId == translator.id }) {
            errorMessage = "You already have a request with this translator"
            completion(false)
            return
        }
        
        FirebaseService.shared.createAppointment(
            deafUserId: deafUserId,
            deafName: deafName,
            translatorId: translator.id
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.fetchTranslators()
                    self?.createConversation(with: translator)
                    self?.openChatWith = translator
                    completion(true)
                case .failure(let error):
                    self?.errorMessage = "Failed to create appointment: \(error.localizedDescription)"
                    completion(false)
                }
            }
        }
    }
    
    func createConversation(with translator: TranslatorData) {
        if conversations.contains(where: { $0.translatorId == translator.id }) { return }
        let newChat = Conversation(translatorId: translator.id, translatorName: translator.name)
        conversations.append(newChat)
    }
    
    // MARK: - Cancel Appointment
    func cancelAppointment(appointmentId: String) {
        // Find the translator ID before deleting
        if let appointment = appointments.first(where: { $0.id == appointmentId }) {
            let translatorId = appointment.translatorId
            
            FirebaseService.shared.deleteAppointment(appointmentId: appointmentId) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        print("✅ Appointment cancelled successfully")
                        // Remove the conversation associated with this translator
                        self?.removeConversation(translatorId: translatorId)
                        
                        // Refresh data
                        self?.fetchUserAppointments()
                        self?.forceRematchAppointments()
                        
                    case .failure(let error):
                        self?.errorMessage = "Failed to cancel appointment: \(error.localizedDescription)"
                    }
                }
            }
        }
    }

    // MARK: - Remove Conversation
    func removeConversation(translatorId: String) {
        conversations.removeAll { $0.translatorId == translatorId }
        print("🗑️ Removed conversation for translator: \(translatorId)")
    }

    

    // MARK: - Latest Translators
    var limitedTranslators: [TranslatorData] {
        Array(allTranslators.prefix(3))
    }
}
