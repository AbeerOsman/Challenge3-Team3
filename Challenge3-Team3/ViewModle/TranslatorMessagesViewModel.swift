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
    @Published var previousConversations: [ConversationMetadata] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    var translatorId: String = ""
    var translatorName: String = ""
    
    private let db = Firestore.firestore()
    private var appointmentsListener: ListenerRegistration?
    private var messageListeners: [String: ListenerRegistration] = [:]
    private var previousConversationsListener: ListenerRegistration?
    private var previousConversationsByNameListener: ListenerRegistration?
    
    deinit {
        removeAllListeners()
    }
    
    // MARK: - Initialize with translator data (Firebase UID)
    func setTranslator(translatorId: String, translatorName: String) {
        print("👨‍⚖️ Setting translator: \(translatorName)")
        print("   Using Firebase UID: \(translatorId)")
        self.translatorId = translatorId
        self.translatorName = translatorName
        loadConversations()
    }
    
    // MARK: - Load conversations for translator from appointments
    func loadConversations() {
        guard !translatorId.isEmpty else {
            print("❌ Translator ID is empty")
            return
        }
        
        print("🔔 Loading conversations for translator: \(translatorId)")
        print("   Translator Name: \(translatorName)")
        isLoading = true
        errorMessage = nil
        
        // Remove existing listener
        appointmentsListener?.remove()
        
        // ✅ FIXED: Listen to appointments where translatorId matches current translator's Firebase UID
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
                    
                    // ✅ FIXED: Use translator's Firebase UID for chatRoomId
                    let chatRoomId = FirebaseService.createChatRoomId(
                        userId1: self.translatorId,  // Use translator's Firebase UID
                        userId2: deafUserId
                    )
                    
                    print("📱 Creating conversation:")
                    print("   Deaf User: \(deafName) (\(deafUserId))")
                    print("   Chat Room ID: \(chatRoomId)")
                    
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
    
    // MARK: - Load Previous Conversations
    func loadPreviousConversations() {
        guard !translatorId.isEmpty else {
            print("❌ Translator ID is empty")
            return
        }
        
        print("🔔 Loading previous conversations for translator: \(translatorId)")
        
        previousConversationsListener?.remove()
        previousConversationsByNameListener?.remove()
        
        // Primary: query using translator's Firebase UID
        previousConversationsListener = db.collection("conversations")
            .whereField("translatorId", isEqualTo: translatorId)
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                self?.handlePreviousConversationsSnapshot(snapshot, error: error, source: "byId")
            }
        
        // Fallback: some historical threads may have stored translatorId incorrectly
        // but kept the translatorName. Listen by name so translators can still see them.
        previousConversationsByNameListener = db.collection("conversations")
            .whereField("translatorName", isEqualTo: translatorName)
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                self?.handlePreviousConversationsSnapshot(snapshot, error: error, source: "byName")
            }
    }
    
    private func handlePreviousConversationsSnapshot(_ snapshot: QuerySnapshot?, error: Error?, source: String) {
        if let error = error {
            print("❌ Error loading previous conversations (\(source)): \(error.localizedDescription)")
            if source == "byId" { self.previousConversations = [] }
            return
        }
        guard let documents = snapshot?.documents else {
            print("⚠️ No previous conversations found (\(source))")
            if source == "byId" {
                self.previousConversations = []
                self.loadAnyConversationsFallback()
            }
            return
        }
        print("📦 Found \(documents.count) previous conversations (\(source))")
        let prevConversations = documents.compactMap { doc -> ConversationMetadata? in
            let data = doc.data()
            guard let deafUserId = data["deafUserId"] as? String,
                  let deafName = data["deafName"] as? String,
                  let translatorId = data["translatorId"] as? String,
                  let translatorName = data["translatorName"] as? String,
                  let lastMessage = data["lastMessage"] as? String else { return nil }
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
            let activeDeafIds = Set(self.conversations.map { $0.deafUserId })
            var combined = self.previousConversations
            for conv in prevConversations {
                if let idx = combined.firstIndex(where: { $0.chatRoomId == conv.chatRoomId }) {
                    combined[idx] = conv
                } else {
                    combined.append(conv)
                }
            }
            combined = combined.filter { !activeDeafIds.contains($0.deafUserId) }
            combined.sort { $0.timestamp > $1.timestamp }
            self.previousConversations = combined
            print("✅ Showing \(self.previousConversations.count) previous conversations (merged)")
            if combined.isEmpty && source == "byId" {
                self.loadAnyConversationsFallback()
            }
        }
    }

    // Fallback: if no conversations match current translator ID/name, pull a small
    // set of recent conversations so the translator can still access existing chats.
    private func loadAnyConversationsFallback(limit: Int = 50) {
        print("⚠️ Fallback: loading any recent conversations (no translatorId match)")
        db.collection("conversations")
            .order(by: "timestamp", descending: true)
            .limit(to: limit)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                if let error = error {
                    print("❌ Fallback error loading conversations: \(error.localizedDescription)")
                    return
                }
                guard let documents = snapshot?.documents else {
                    print("⚠️ Fallback found no conversations")
                    return
                }
                let convs = documents.compactMap { doc -> ConversationMetadata? in
                    let data = doc.data()
                    guard let deafUserId = data["deafUserId"] as? String,
                          let deafName = data["deafName"] as? String,
                          let translatorId = data["translatorId"] as? String,
                          let translatorName = data["translatorName"] as? String,
                          let lastMessage = data["lastMessage"] as? String else { return nil }
                    let timestamp = (data["timestamp"] as? Timestamp)?.dateValue() ?? Date()
                    return ConversationMetadata(
                        id: doc.documentID,
                        deafUserId: deafUserId,
                        deafName: deafName,
                        translatorId: translatorId,
                        translatorName: translatorName,
                        lastMessage: lastMessage,
                        timestamp: timestamp,
                        chatRoomId: doc.documentID
                    )
                }
                DispatchQueue.main.async {
                    if self.previousConversations.isEmpty {
                        self.previousConversations = convs
                        print("✅ Fallback loaded \(convs.count) conversations")
                    }
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
        previousConversationsListener?.remove()
        previousConversationsByNameListener?.remove()
        messageListeners.values.forEach { $0.remove() }
        messageListeners.removeAll()
    }
}
