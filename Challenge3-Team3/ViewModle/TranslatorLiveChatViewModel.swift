import SwiftUI
import FirebaseFirestore
import Combine
import UserNotifications

class TranslatorLiveChatViewModel: ObservableObject {
    
    @Published var messages: [Message] = []
    @Published var messageText: String = ""
    
    // FaceTime states
    @Published var showFaceTimeConfirmation = false
    @Published var showFaceTimeAlert = false
    @Published var alertMessage = ""
    @Published var showAppleLoginSheet = false
    
    private let db = Firestore.firestore()
    private let currentUserId: String
    private let currentUserName: String
    private let recipientUserId: String
    private let recipientName: String
    private let chatRoomId: String
    
    private var lastMessageCount = 0
    private var messagesListener: ListenerRegistration?
    
    init(currentUserId: String,
         currentUserName: String,
         recipientUserId: String,
         recipientName: String,
         chatRoomId: String) {
        
        self.currentUserId = currentUserId
        self.currentUserName = currentUserName
        self.recipientUserId = recipientUserId
        self.recipientName = recipientName
        self.chatRoomId = chatRoomId
        
        print("🔥 TranslatorLiveChatViewModel initialized")
        print("   Current User (Translator): \(currentUserName) (\(currentUserId))")
        print("   Recipient (Deaf User): \(recipientName) (\(recipientUserId))")
        print("   Chat Room ID: \(chatRoomId)")
        
        requestNotificationPermissions()
        loadMessages()
    }

    private func requestNotificationPermissions() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }
    
    private func notifyNewMessage(from senderName: String, messageText: String) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        guard UIApplication.shared.applicationState != .active else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "💬 \(senderName)"
        content.body = messageText
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        )
        
        UNUserNotificationCenter.current().add(request)
    }

    func sendMessage() {
        guard !messageText.isEmpty else {
            print("⚠️ Cannot send empty message")
            return
        }
        
        print("📤 Translator attempting to send message...")
        print("   Text: \(messageText)")
        print("   From: \(currentUserName) (\(currentUserId))")
        print("   To Chat Room: \(chatRoomId)")
        
        let msg = Message(
            text: messageText,
            senderId: currentUserId,
            senderName: currentUserName
        )
        
        let data: [String: Any] = [
            "id": msg.id,
            "text": msg.text,
            "senderId": msg.senderId,
            "senderName": msg.senderName,
            "timestamp": Timestamp(date: msg.timestamp)
        ]
        
        db.collection("chatRooms")
            .document(chatRoomId)
            .collection("messages")
            .document(msg.id)
            .setData(data) { [weak self] error in
                if let error = error {
                    print("❌ Translator: Error sending message: \(error.localizedDescription)")
                } else {
                    print("✅ Translator: Message sent successfully to Firestore")
                    print("   Path: chatRooms/\(self?.chatRoomId ?? "N/A")/messages/\(msg.id)")
                    self?.messageText = ""
                }
            }
    }

    func loadMessages() {
        print("🎧 Translator: Setting up message listener...")
        print("   Chat Room ID: \(chatRoomId)")
        
        messagesListener?.remove()
        
        messagesListener = db.collection("chatRooms")
            .document(chatRoomId)
            .collection("messages")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("❌ Translator: Error listening to messages: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("⚠️ Translator: No documents in snapshot")
                    return
                }
                
                print("📦 Translator: Received snapshot with \(documents.count) documents")
                
                let newMessages = documents.compactMap { doc -> Message? in
                    let data = doc.data()
                    
                    guard let id = data["id"] as? String,
                          let text = data["text"] as? String,
                          let senderId = data["senderId"] as? String,
                          let senderName = data["senderName"] as? String,
                          let timestamp = data["timestamp"] as? Timestamp else {
                        print("⚠️ Translator: Failed to decode message from doc: \(doc.documentID)")
                        return nil
                    }
                    
                    return Message(
                        id: id,
                        text: text,
                        senderId: senderId,
                        senderName: senderName,
                        timestamp: timestamp.dateValue()
                    )
                }
                
                print("✅ Translator: Successfully decoded \(newMessages.count) messages")
                newMessages.forEach { msg in
                    print("   - \(msg.senderName): \(msg.text)")
                }
                
                if newMessages.count > self.lastMessageCount,
                   let latest = newMessages.last,
                   latest.senderId == self.recipientUserId {
                    print("🔔 Translator: New message from deaf user!")
                    self.notifyNewMessage(from: latest.senderName, messageText: latest.text)
                }
                
                DispatchQueue.main.async {
                    self.messages = newMessages
                    self.lastMessageCount = newMessages.count
                }
            }
    }
    
    func requestFaceTimeCall() {
        showFaceTimeConfirmation = true
    }
    
    func openFaceTime() {
        let cleaned = ""
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")
        
        guard let url = URL(string: "facetime://\(cleaned)") else {
            alertMessage = "Invalid contact information"
            showFaceTimeAlert = true
            return
        }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url) { success in
                if !success {
                    self.alertMessage = "Unable to open FaceTime"
                    self.showFaceTimeAlert = true
                }
            }
        } else {
            alertMessage = "FaceTime is not available on this device"
            showFaceTimeAlert = true
        }
    }
    
    deinit {
        messagesListener?.remove()
        print("🧹 TranslatorLiveChatViewModel deinitialized, listeners removed")
    }
}
