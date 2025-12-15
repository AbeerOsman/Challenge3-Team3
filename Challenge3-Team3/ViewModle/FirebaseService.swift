import Foundation
import FirebaseFirestore

class FirebaseService {
    static let shared = FirebaseService()
    private let db = Firestore.firestore()
    
    private var translatorsListener: ListenerRegistration?
    private var appointmentsListener: ListenerRegistration?
    
    private init() {
        print("🔥 FirebaseService initialized")
    }
    
    // MARK: - Chat Room ID Helper (✅ FIXED)
    static func createChatRoomId(userId1: String, userId2: String) -> String {
        return [userId1, userId2]
            .sorted()
            .joined(separator: "_")
    }
    
    // MARK: - Translators (users collection)
    func fetchTranslators(completion: @escaping (Result<[TranslatorData], Error>) -> Void) {
        print("🔔 Setting up translators listener...")
        
        translatorsListener?.remove()
        
        translatorsListener = db.collection("users")
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error fetching translators: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("No documents found in snapshot")
                    completion(.success([]))
                    return
                }
                
                print("Found \(documents.count) documents in 'users' collection")
                
                let translators = documents.compactMap { doc -> TranslatorData? in
                    let data = doc.data()
                    
                    let name = data["name"] as? String ?? ""
                    let gender = data["gender"] as? String ?? ""
                    let age = data["age"] as? Int ?? 0
                    let level = data["level"] as? String ?? ""
                    
                    var price = 0
                    var category = ""
                    
                    // Handle price field (can be "price" or "hourlyRate")
                    if let priceValue = data["price"] as? Int {
                        price = priceValue
                        category = data["category"] as? String ?? ""
                    } else if let hourlyRate = data["hourlyRate"] as? Int {
                        price = hourlyRate
                        category = data["plan"] as? String ?? ""
                    } else if let hourlyRate = data["hourlyRate"] as? Double {
                        price = Int(hourlyRate)
                        category = data["plan"] as? String ?? ""
                    }
                    
                    // Handle multiple careers
                    var careersArray: [String] = []
                    var careerDisplayString = ""
                    
                    if let careersFromFirebase = data["careers"] as? [String] {
                        careersArray = careersFromFirebase.filter { !$0.isEmpty && $0 != "بدون" }
                        careerDisplayString = careersArray.joined(separator: "، ")
                    } else if let singleCareer = data["career"] as? String {
                        if !singleCareer.isEmpty && singleCareer != "بدون" {
                            careersArray = [singleCareer]
                            careerDisplayString = singleCareer
                        }
                    }
                    
                    guard !name.isEmpty && !level.isEmpty else {
                        return nil
                    }
                    
                    // ✅ Get Firebase UID - use the document ID which IS the Firebase UID
                    let firebaseUID = doc.documentID
                    
                    return TranslatorData(
                        id: doc.documentID,
                        firebaseUID: firebaseUID,
                        name: name,
                        gender: gender,
                        age: "\(age)",
                        level: level,
                        price: "\(price)",
                        category: category,
                        career: careerDisplayString,
                        careers: careersArray
                    )
                }
                
                print("Successfully created \(translators.count) translator objects")
                completion(.success(translators))
            }
    }

    // Same update for fetchTranslatorsByLevel
    func fetchTranslatorsByLevel(level: String, completion: @escaping (Result<[TranslatorData], Error>) -> Void) {
        print("🔔 Setting up level filter listener for: \(level)")
        
        translatorsListener?.remove()
        
        translatorsListener = db.collection("users")
            .whereField("level", isEqualTo: level)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("❌ Error filtering translators: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("⚠️ No documents found for level: \(level)")
                    completion(.success([]))
                    return
                }
                
                print("📦 Found \(documents.count) translators with level: \(level)")
                
                let translators = documents.compactMap { doc -> TranslatorData? in
                    let data = doc.data()
                    
                    let name = data["name"] as? String ?? ""
                    let gender = data["gender"] as? String ?? ""
                    let age = data["age"] as? Int ?? 0
                    let level = data["level"] as? String ?? ""
                    
                    var price = 0
                    var category = ""
                    
                    if let priceValue = data["price"] as? Int {
                        price = priceValue
                        category = data["category"] as? String ?? ""
                    } else if let hourlyRate = data["hourlyRate"] as? Int {
                        price = hourlyRate
                        category = data["plan"] as? String ?? ""
                    } else if let hourlyRate = data["hourlyRate"] as? Double {
                        price = Int(hourlyRate)
                        category = data["plan"] as? String ?? ""
                    }
                    
                    var careersArray: [String] = []
                    var careerDisplayString = ""
                    
                    if let careersFromFirebase = data["careers"] as? [String] {
                        careersArray = careersFromFirebase.filter { !$0.isEmpty && $0 != "بدون" }
                        careerDisplayString = careersArray.joined(separator: "، ")
                    } else if let singleCareer = data["career"] as? String {
                        if !singleCareer.isEmpty && singleCareer != "بدون" {
                            careersArray = [singleCareer]
                            careerDisplayString = singleCareer
                        }
                    }
                    
                    guard !name.isEmpty && !level.isEmpty else {
                        return nil
                    }
                    
                    // ✅ Get Firebase UID
                    let firebaseUID = doc.documentID
                    
                    return TranslatorData(
                        id: doc.documentID,
                        firebaseUID: firebaseUID,
                        name: name,
                        gender: gender,
                        age: "\(age)",
                        level: level,
                        price: "\(price)",
                        category: category,
                        career: careerDisplayString,
                        careers: careersArray
                    )
                }
                
                completion(.success(translators))
            }
    }
    
    // MARK: - Appointments
    func createAppointment(
        deafUserId: String,
        deafName: String,
        translatorId: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        print("🔔 Creating appointment request...")
        print("   Deaf User: \(deafName) (\(deafUserId))")
        print("   Translator ID: \(translatorId)")
        
        let appointmentData: [String: Any] = [
            "deafUserId": deafUserId,
            "deafName": deafName,
            "translatorId": translatorId,
            "createdAt": FieldValue.serverTimestamp()
        ]
        
        db.collection("appointments").addDocument(data: appointmentData) { error in
            if let error = error {
                print("❌ Error creating appointment: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            print("✅ Appointment created successfully with createdAt timestamp")
            completion(.success("Appointment created"))
        }
    }
    
    func fetchUserAppointments(
        userId: String,
        completion: @escaping (Result<[AppointmentRequest], Error>) -> Void
    ) {
        print("🔔 Setting up appointments listener for user: \(userId)")
        
        appointmentsListener?.remove()
        
        appointmentsListener = db.collection("appointments")
            .whereField("deafUserId", isEqualTo: userId)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("❌ Error fetching appointments: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("⚠️ No appointments found")
                    completion(.success([]))
                    return
                }
                
                print("📦 Found \(documents.count) appointments")
                
                let appointments = documents.compactMap { doc -> AppointmentRequest? in
                    do {
                        var appointment = try doc.data(as: AppointmentRequest.self)
                        appointment.id = doc.documentID
                        return appointment
                    } catch {
                        print("❌ Error decoding appointment: \(error)")
                        return nil
                    }
                }
                
                print("✅ Successfully decoded \(appointments.count) appointments")
                completion(.success(appointments))
            }
    }
    
    func deleteAppointment(
        appointmentId: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        print("🗑️ Deleting appointment: \(appointmentId)")
        
        db.collection("appointments").document(appointmentId).delete { error in
            if let error = error {
                print("❌ Error deleting appointment: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            print("✅ Appointment deleted successfully")
            completion(.success(()))
        }
    }
    
    // MARK: - Cascade Delete User Appointments
    func deleteAllUserAppointments(
        userId: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        print("🗑️ Deleting all appointments for user: \(userId)")
        
        db.collection("appointments")
            .whereField("deafUserId", isEqualTo: userId)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("❌ Error fetching appointments for deletion: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("⚠️ No appointments found for user: \(userId)")
                    completion(.success(()))
                    return
                }
                
                print("📦 Found \(documents.count) appointments to delete for user: \(userId)")
                
                if documents.isEmpty {
                    print("✅ No appointments to delete")
                    completion(.success(()))
                    return
                }
                
                let batch = self.db.batch()
                
                for document in documents {
                    batch.deleteDocument(document.reference)
                    print("   ➕ Marked appointment for deletion: \(document.documentID)")
                }
                
                batch.commit { error in
                    if let error = error {
                        print("❌ Error batch deleting appointments: \(error.localizedDescription)")
                        completion(.failure(error))
                        return
                    }
                    
                    print("✅ Successfully deleted \(documents.count) appointments for user: \(userId)")
                    completion(.success(()))
                }
            }
    }
    
    // MARK: - Conversation Metadata (✅ NEW)
    func createOrUpdateConversation(
        deafUserId: String,
        deafName: String,
        translatorId: String,
        translatorName: String,
        lastMessage: String,
        chatRoomId: String
    ) {
        print("💾 Creating/Updating conversation metadata for: \\(chatRoomId)")
        
        let conversationData: [String: Any] = [
            "deafUserId": deafUserId,
            "deafName": deafName,
            "translatorId": translatorId,
            "translatorName": translatorName,
            "lastMessage": lastMessage,
            "timestamp": FieldValue.serverTimestamp(),
            "chatRoomId": chatRoomId
        ]
        
        db.collection("conversations")
            .document(chatRoomId)
            .setData(conversationData, merge: true) { error in
                if let error = error {
                    print("❌ Error updating conversation: \\(error.localizedDescription)")
                } else {
                    print("✅ Conversation metadata updated")
                }
            }
        
        // Keep a lightweight chat room document so both roles can reopen the same
        // thread and see the last message even before loading messages.
        let chatRoomData: [String: Any] = [
            "participants": [deafUserId, translatorId],
            "deafUserId": deafUserId,
            "deafName": deafName,
            "translatorId": translatorId,
            "translatorName": translatorName,
            "lastMessage": lastMessage,
            "updatedAt": FieldValue.serverTimestamp()
        ]
        
        db.collection("chatRooms")
            .document(chatRoomId)
            .setData(chatRoomData, merge: true) { error in
                if let error = error {
                    print("⚠️ Error updating chatRoom metadata: \\(error.localizedDescription)")
                } else {
                    print("✅ chatRoom metadata synced")
                }
            }
    }
    
    // MARK: - Load Previous Conversations (✅ NEW)
    func loadPreviousConversations(
        deafUserId: String,
        completion: @escaping (Result<[ConversationMetadata], Error>) -> Void
    ) {
        print("🔔 Loading previous conversations for deaf user: \(deafUserId)")
        
        db.collection("conversations")
            .whereField("deafUserId", isEqualTo: deafUserId)
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("❌ Error loading conversations: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("⚠️ No previous conversations found")
                    completion(.success([]))
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
                
                print("✅ Successfully loaded \(conversations.count) conversations")
                completion(.success(conversations))
            }
    }
    
    func removeAllListeners() {
        print("🧹 Removing all Firebase listeners")
        translatorsListener?.remove()
        appointmentsListener?.remove()
    }
    
    // MARK: - Deaf users
    func deleteDeafUser(
        userId: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        print("🗑️ Deleting deaf user from 'deafUsers': \(userId)")
        
        db.collection("deafUsers").document(userId).delete { error in
            if let error = error {
                print("❌ Error deleting deaf user: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            print("✅ Deaf user deleted from 'deafUsers'")
            completion(.success(()))
        }
    }
    
    func debugCheckMessages(chatRoomId: String) {
        print("🔍 DEBUG: Checking messages in chatRoom: \(chatRoomId)")
        
        db.collection("chatRooms")
            .document(chatRoomId)
            .collection("messages")
            .getDocuments { snapshot, error in
                if let error = error {
                    print("❌ Error checking messages: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("⚠️ No messages found in chatRoom: \(chatRoomId)")
                    return
                }
                
                print("📦 Found \(documents.count) messages in chatRoom: \(chatRoomId)")
                for (index, doc) in documents.enumerated() {
                    let data = doc.data()
                    print("   Message \(index + 1):")
                    print("     ID: \(data["id"] as? String ?? "N/A")")
                    print("     Text: \(data["text"] as? String ?? "N/A")")
                    print("     From: \(data["senderName"] as? String ?? "N/A")")
                    print("     Sender ID: \(data["senderId"] as? String ?? "N/A")")
                }
            }
    }
    
    // delete old messages when an appointment is removed
    func deleteConversationMessages(chatRoomId: String) {
        db.collection("chatRooms")
            .document(chatRoomId)
            .collection("messages")
            .getDocuments { snapshot, _ in
                let batch = self.db.batch()
                snapshot?.documents.forEach { doc in
                    batch.deleteDocument(doc.reference)
                }
                batch.commit()
            }
    }
    
    // Delete a single conversation metadata doc
    func deleteConversationDocument(chatRoomId: String) {
        db.collection("conversations").document(chatRoomId).delete { error in
            if let error = error {
                print("⚠️ Error deleting conversation doc: \(error.localizedDescription)")
            } else {
                print("✅ Conversation doc deleted: \(chatRoomId)")
            }
        }
    }
    
    // Delete chatRoom shell document
    func deleteChatRoomDocument(chatRoomId: String) {
        db.collection("chatRooms").document(chatRoomId).delete { error in
            if let error = error {
                print("⚠️ Error deleting chatRoom doc: \(error.localizedDescription)")
            } else {
                print("✅ chatRoom doc deleted: \(chatRoomId)")
            }
        }
    }
    
    // Delete all chats for a deaf user (messages + chatRoom + conversation)
    func deleteAllChatsForDeaf(userId: String, completion: ((Result<Void, Error>) -> Void)? = nil) {
        print("🧹 Deleting all chats for deaf user: \(userId)")
        db.collection("conversations")
            .whereField("deafUserId", isEqualTo: userId)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("❌ Error fetching conversations for deletion: \(error.localizedDescription)")
                    completion?(.failure(error))
                    return
                }
                
                guard let docs = snapshot?.documents else {
                    completion?(.success(()))
                    return
                }
                
                let group = DispatchGroup()
                for doc in docs {
                    let chatRoomId = doc.documentID
                    group.enter()
                    self.deleteConversationMessages(chatRoomId: chatRoomId)
                    self.deleteChatRoomDocument(chatRoomId: chatRoomId)
                    self.deleteConversationDocument(chatRoomId: chatRoomId)
                    group.leave()
                }
                
                group.notify(queue: .main) {
                    print("✅ Deleted \(docs.count) chat threads for deaf user \(userId)")
                    completion?(.success(()))
                }
            }
    }
    
    // Delete all chats for a translator but leave a notice in conversation docs
    func deleteAllChatsForTranslator(userId: String, completion: ((Result<Void, Error>) -> Void)? = nil) {
        print("🧹 Deleting all chats for translator: \(userId)")
        db.collection("conversations")
            .whereField("translatorId", isEqualTo: userId)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("❌ Error fetching conversations for translator deletion: \(error.localizedDescription)")
                    completion?(.failure(error))
                    return
                }
                
                guard let docs = snapshot?.documents else {
                    completion?(.success(()))
                    return
                }
                
                let group = DispatchGroup()
                for doc in docs {
                    let chatRoomId = doc.documentID
                    group.enter()
                    // wipe messages + chatRoom
                    self.deleteConversationMessages(chatRoomId: chatRoomId)
                    self.deleteChatRoomDocument(chatRoomId: chatRoomId)
                    // leave notice so deaf user knows translator deleted account
                    let notice: [String: Any] = [
                        "lastMessage": "هذا المترجم قام بحذف حسابه والرسائل",
                        "translatorDeleted": true,
                        "timestamp": FieldValue.serverTimestamp()
                    ]
                    self.db.collection("conversations").document(chatRoomId).setData(notice, merge: true) { _ in
                        group.leave()
                    }
                }
                
                group.notify(queue: .main) {
                    print("✅ Deleted chat threads for translator \(userId) and left notices")
                    completion?(.success(()))
                }
            }
    }
    
    

    // Delete a single message from a chat room
    func deleteMessage(chatRoomId: String, messageId: String) {
        db.collection("chatRooms")
            .document(chatRoomId)
            .collection("messages")
            .document(messageId)
            .delete { error in
                if let error = error {
                    print("⚠️ Error deleting message: \(error.localizedDescription)")
                } else {
                    print("✅ Deleted message \(messageId) in chatRoom \(chatRoomId)")
                }
            }
    }
    // Add this debug method to FirebaseService.swift

    func debugCheckTranslatorIds() {
        print("\n🔍 DEBUG: Checking all translator IDs in system...\n")
        
        // Check users collection
        db.collection("users").getDocuments { snapshot, error in
            if let error = error {
                print("❌ Error fetching users: \(error)")
                return
            }
            
            print("📋 USERS COLLECTION:")
            snapshot?.documents.forEach { doc in
                let data = doc.data()
                let name = data["name"] as? String ?? "Unknown"
                let uid = doc.documentID
                print("   Document ID (Firebase UID): \(uid)")
                print("   Name: \(name)")
                print("   ---")
            }
        }
        
        // Check appointments collection
        db.collection("appointments").getDocuments { snapshot, error in
            if let error = error {
                print("❌ Error fetching appointments: \(error)")
                return
            }
            
            print("\n📋 APPOINTMENTS COLLECTION:")
            snapshot?.documents.forEach { doc in
                let data = doc.data()
                let deafName = data["deafName"] as? String ?? "Unknown"
                let translatorId = data["translatorId"] as? String ?? "Unknown"
                print("   Appointment ID: \(doc.documentID)")
                print("   Deaf User: \(deafName)")
                print("   Translator ID (stored): \(translatorId)")
                print("   ---")
            }
        }
        
        // Check conversations collection
        db.collection("conversations").getDocuments { snapshot, error in
            if let error = error {
                print("❌ Error fetching conversations: \(error)")
                return
            }
            
            print("\n📋 CONVERSATIONS COLLECTION:")
            snapshot?.documents.forEach { doc in
                let data = doc.data()
                let deafName = data["deafName"] as? String ?? "Unknown"
                let translatorId = data["translatorId"] as? String ?? "Unknown"
                let translatorName = data["translatorName"] as? String ?? "Unknown"
                print("   Chat Room ID: \(doc.documentID)")
                print("   Deaf User: \(deafName)")
                print("   Translator ID: \(translatorId)")
                print("   Translator Name: \(translatorName)")
                print("   ---")
            }
        }
    }
}

// MARK: - Conversation Metadata Model (✅ NEW)
struct ConversationMetadata: Identifiable {
    let id: String
    let deafUserId: String
    let deafName: String
    let translatorId: String
    let translatorName: String
    let lastMessage: String
    let timestamp: Date
    let chatRoomId: String
}

