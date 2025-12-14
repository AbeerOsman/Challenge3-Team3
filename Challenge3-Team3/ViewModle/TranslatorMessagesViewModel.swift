import Foundation
import Combine
import FirebaseFirestore

// MARK: - Translator Conversation Model
struct TranslatorConversation: Identifiable {
    let id: String
    let deafUserId: String
    let deafName: String
    let deafGender: String
    let lastMessage: String
    let timestamp: Date
    let chatRoomId: String
    
    init(deafUserId: String,
         deafName: String,
         deafGender: String = "ذكر",
         lastMessage: String = "تم إنشاء المحادثة",
         timestamp: Date = Date(),
         chatRoomId: String) {
        self.id = UUID().uuidString
        self.deafUserId = deafUserId
        self.deafName = deafName
        self.deafGender = deafGender
        self.lastMessage = lastMessage
        self.timestamp = timestamp
        self.chatRoomId = chatRoomId
    }
}

// MARK: - Translator Messages ViewModel
class TranslatorMessagesViewModel: ObservableObject {
    @Published var conversations: [TranslatorConversation] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    var translatorId: String = ""
    var translatorName: String = ""
    
    private let db = Firestore.firestore()
    private var appointmentsListener: ListenerRegistration?
    private var messageListeners: [String: ListenerRegistration] = [:]
    
    deinit {
        removeAllListeners()
    }
    
    // MARK: - Initialize with translator data
    func setTranslator(translatorId: String, translatorName: String) {
        print("👨‍⚖️ Setting translator: \(translatorName) (ID: \(translatorId))")
        self.translatorId = translatorId
        self.translatorName = translatorName
        loadConversations()
    }
    
    // MARK: - Load conversations for translator
    func loadConversations() {
        guard !translatorId.isEmpty else {
            print("❌ Translator ID is empty")
            return
        }
        
        print("🔍 Loading conversations for translator: \(translatorId)")
        print("   Translator Name: \(translatorName)")
        isLoading = true
        errorMessage = nil
        
        // Remove existing listener
        appointmentsListener?.remove()
        
        // Listen to appointments where translatorId matches
        appointmentsListener = db.collection("appointments")
            .whereField("translatorId", isEqualTo: translatorId)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("❌ Error fetching appointments: \(error.localizedDescription)")
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("⚠️ No appointments found")
                    self.isLoading = false
                    self.conversations = []
                    return
                }
                
                print("📦 Found \(documents.count) appointments for this translator")
                
                // Create conversations from appointments
                var newConversations: [TranslatorConversation] = []
                
                for doc in documents {
                    let data = doc.data()
                    
                    guard let deafUserId = data["deafUserId"] as? String,
                          let deafName = data["deafName"] as? String else {
                        print("⚠️ Skipping appointment with missing deaf user data")
                        continue
                    }
                    
                    let chatRoomId = [self.translatorId, deafUserId]
                        .sorted()
                        .joined(separator: "_")
                    
                    // Fetch deaf user profile to get gender
                    self.fetchDeafUserProfile(deafUserId: deafUserId) { gender in
                        // Listen to messages for this chat room
                        self.listenToMessages(chatRoomId: chatRoomId, deafUserId: deafUserId, deafName: deafName, deafGender: gender)
                    }
                    
                    let conversation = TranslatorConversation(
                        deafUserId: deafUserId,
                        deafName: deafName,
                        deafGender: "ذكر", // Default, will be updated from profile
                        lastMessage: "تم إنشاء المحادثة",
                        timestamp: Date(),
                        chatRoomId: chatRoomId
                    )
                    
                    newConversations.append(conversation)
                }
                
                DispatchQueue.main.async {
                    self.conversations = newConversations
                    self.isLoading = false
                }
            }
    }
    
    // MARK: - Fetch deaf user profile
    private func fetchDeafUserProfile(deafUserId: String, completion: @escaping (String) -> Void) {
        db.collection("deafUsers")
            .document(deafUserId)
            .getDocument { snapshot, error in
                if let error = error {
                    print("⚠️ Error fetching deaf user profile: \(error.localizedDescription)")
                    completion("ذكر")
                    return
                }
                
                guard let data = snapshot?.data() else {
                    completion("ذكر")
                    return
                }
                
                let gender = data["gender"] as? String ?? "ذكر"
                completion(gender)
            }
    }
    
    // MARK: - Listen to messages for a chat room
    private func listenToMessages(chatRoomId: String, deafUserId: String, deafName: String, deafGender: String) {
        print("🎧 Listening to messages for chat room: \(chatRoomId)")
        
        // Remove existing listener if any
        messageListeners[chatRoomId]?.remove()
        
        messageListeners[chatRoomId] = db.collection("chatRooms")
            .document(chatRoomId)
            .collection("messages")
            .order(by: "timestamp", descending: true)
            .limit(to: 1)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("⚠️ Error listening to messages: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents,
                      let latestMessage = documents.first?.data() else {
                    return
                }
                
                let lastMessage = latestMessage["text"] as? String ?? "تم إنشاء المحادثة"
                let timestamp = (latestMessage["timestamp"] as? Timestamp)?.dateValue() ?? Date()
                
                // Update conversation with latest message
                DispatchQueue.main.async {
                    if let index = self.conversations.firstIndex(where: { $0.deafUserId == deafUserId }) {
                        var updated = self.conversations[index]
                        updated = TranslatorConversation(
                            deafUserId: deafUserId,
                            deafName: deafName,
                            deafGender: deafGender,
                            lastMessage: lastMessage,
                            timestamp: timestamp,
                            chatRoomId: chatRoomId
                        )
                        self.conversations[index] = updated
                        
                        // Sort by timestamp (most recent first)
                        self.conversations.sort { $0.timestamp > $1.timestamp }
                    }
                }
            }
    }
    
    // MARK: - Remove all listeners
    private func removeAllListeners() {
        print("🧹 Removing all message listeners")
        appointmentsListener?.remove()
        messageListeners.values.forEach { $0.remove() }
        messageListeners.removeAll()
    }
}
