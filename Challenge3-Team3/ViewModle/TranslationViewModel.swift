import Foundation
import Combine
import FirebaseFirestore
import FirebaseAuth

// MARK: - Conversation Model
struct Conversation: Identifiable {
    let id: String
    let translatorId: String
    let translatorName: String
    let lastMessage: String
    let timestamp: Date
    let gender: String
    
    init(translatorId: String,
         translatorName: String,
         lastMessage: String = "تم إنشاء المحادثة",
         timestamp: Date = Date(),
         gender: String = "ذكر"
    ) {
        self.id = UUID().uuidString
        self.translatorId = translatorId
        self.translatorName = translatorName
        self.lastMessage = lastMessage
        self.timestamp = timestamp
        self.gender = gender
    }
}

// MARK: - Translation ViewModel
class TranslationViewModel: ObservableObject {
    @Published var openChatWith: TranslatorData? = nil
    @Published var selectedLevel: TranslatorLevel? = nil
    @Published var allTranslators: [TranslatorData] = [] {
        didSet { matchAppointmentsWithTranslators() }
    }
    @Published var translators: [TranslatorData] = []
    @Published var appointments: [AppointmentRequest] = []
    @Published var appointmentsWithTranslators: [AppointmentWithTranslator] = []
    @Published var conversations: [Conversation] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    @Published var previousConversations: [ConversationMetadata] = []
    
    private let db = Firestore.firestore()
    private var conversationsListener: ListenerRegistration?
    private var previousConversationsListener: ListenerRegistration?
    
    var deafUserId: String = ""
    var deafName: String = ""
    
    // MARK: - Set current deaf user (use Firebase UID)
    func setDeafUser(userId: String, name: String) {
        print("👤 Setting deaf user: \(name)")
        print("   Using Firebase UID: \(userId)")
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
            // ✅ Match by firebaseUID
            let translator = allTranslators.first { $0.firebaseUID == appointment.translatorId }
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
        
        // ✅ Check using firebaseUID
        if appointments.contains(where: { $0.translatorId == translator.firebaseUID }) {
            errorMessage = "You already have a request with this translator"
            completion(false)
            return
        }
        
        print("📱 Requesting appointment with translator:")
        print("   Translator ID (Firebase UID): \(translator.firebaseUID)")
        print("   Translator Name: \(translator.name)")
        
        FirebaseService.shared.createAppointment(
            deafUserId: deafUserId,
            deafName: deafName,
            translatorId: translator.firebaseUID  // ✅ USE firebaseUID
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
    
    // ✅ FIXED: Use firebaseUID consistently
    func createConversation(with translator: TranslatorData) {
        print("💬 Creating conversation with translator:")
        print("   Using Firebase UID: \(translator.firebaseUID)")
        
        if conversations.contains(where: { $0.translatorId == translator.firebaseUID }) {
            print("⚠️ Conversation already exists")
            return
        }
        
        let newChat = Conversation(
            translatorId: translator.firebaseUID,  // ✅ IMPORTANT: Use firebaseUID
            translatorName: translator.name
        )
        conversations.append(newChat)
        print("✅ Conversation created")
    }
    
    // MARK: - Cancel Appointment (also delete chat thread)
    func cancelAppointment(appointmentId: String) {
        if let appointment = appointments.first(where: { $0.id == appointmentId }) {
            let translatorId = appointment.translatorId
            let chatRoomId = FirebaseService.createChatRoomId(userId1: deafUserId, userId2: translatorId)
            
            FirebaseService.shared.deleteAppointment(appointmentId: appointmentId) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        print("✅ Appointment cancelled successfully")
                        // Wipe chat thread for both sides
                        FirebaseService.shared.deleteConversationMessages(chatRoomId: chatRoomId)
                        FirebaseService.shared.deleteChatRoomDocument(chatRoomId: chatRoomId)
                        FirebaseService.shared.deleteConversationDocument(chatRoomId: chatRoomId)
                        self?.removeConversation(translatorId: translatorId)
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
    
    // MARK: - Load Previous Conversations
    func loadPreviousConversations() {
        guard !deafUserId.isEmpty else {
            print("❌ Deaf User ID is empty")
            return
        }
        
        print("🔔 Loading previous conversations for deaf user: \(deafUserId)")
        
        previousConversationsListener?.remove()
        
        previousConversationsListener = db.collection("conversations")
            .whereField("deafUserId", isEqualTo: deafUserId)
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { [weak self] (snapshot: QuerySnapshot?, error: Error?) in
                guard let self = self else { return }
                
                if let error = error {
                    print("❌ Error loading conversations: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("⚠️ No previous conversations found")
                    self.previousConversations = []
                    return
                }
                
                print("📦 Found \(documents.count) previous conversations")
                
                let conversations = documents.compactMap { doc -> ConversationMetadata? in
                    let data = doc.data()
                    
                    guard let deafUserId = data["deafUserId"] as? String,
                          let deafName = data["deafName"] as? String,
                          let translatorId = data["translatorId"] as? String,
                          let translatorName = data["translatorName"] as? String,
                          let lastMessage = data["lastMessage"] as? String else {
                        return nil
                    }
                    
                    let timestamp = (data["timestamp"] as? Timestamp)?.dateValue() ?? Date()
                    let chatRoomId = doc.documentID
                    
                    return ConversationMetadata(
                        id: doc.documentID,
                        deafUserId: deafUserId,
                        deafName: deafName,
                        translatorId: translatorId,
                        translatorName: translatorName,
                        lastMessage: lastMessage,
                        timestamp: timestamp,
                        chatRoomId: chatRoomId
                    )
                }
                
                DispatchQueue.main.async {
                    let activeTranslatorIds = Set(self.conversations.map { $0.translatorId })
                    self.previousConversations = conversations.filter { !activeTranslatorIds.contains($0.translatorId) }
                    
                    print("✅ Showing \(self.previousConversations.count) previous conversations")
                }
            }
    }
    
    deinit {
        print("🧹 TranslationViewModel deinitialized")
        conversationsListener?.remove()
        previousConversationsListener?.remove()
    }
}
