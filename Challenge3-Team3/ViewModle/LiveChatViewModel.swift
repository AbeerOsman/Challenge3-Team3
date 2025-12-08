//
//  LiveChatViewModel.swift
//  Challenge3-Team3
//
//  Created by Eatzaz Hafiz on 02/12/2025.
//

import SwiftUI
import FirebaseFirestore
import Combine

class LiveChatViewModel: ObservableObject {
    
    @Published var messages: [Message] = []
    @Published var messageText: String = ""
    
    // FaceTime states
    @Published var showFaceTimeConfirmation = false
    @Published var showFaceTimeAlert = false
    @Published var alertMessage = ""
    
    private let db = Firestore.firestore()
    private let currentUserId: String      // ← Current user's ID
    private let currentUserName: String    // ← Current user's name
    private let recipientUserId: String    // ← Other user's ID
    private let recipientName: String      // ← Other user's name
    private let recipientContact: String   // ← Other user's phone/email
    private let chatRoomId: String         // ← Unique chat room ID
    
    init(currentUserId: String,
         currentUserName: String,
         recipientUserId: String,
         recipientName: String,
         recipientContact: String) {
        self.currentUserId = currentUserId
        self.currentUserName = currentUserName
        self.recipientUserId = recipientUserId
        self.recipientName = recipientName
        self.recipientContact = recipientContact
        
        // Create unique chat room ID (alphabetically sorted so it's the same for both users)
        self.chatRoomId = [currentUserId, recipientUserId]
            .sorted()
            .joined(separator: "_")
        
        loadMessages()
    }

    // MARK: - Send Message
    func sendMessage() {
        guard !messageText.isEmpty else { return }
        
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
        
        // Save to the SPECIFIC chat room, not global "chats"
        db.collection("chatRooms")
            .document(chatRoomId)           // ← Unique room for these 2 users
            .collection("messages")          // ← Messages inside this room
            .document(msg.id)
            .setData(data) { error in
                if let error = error {
                    print("Error sending message: \(error)")
                }
            }
        
        messageText = ""
    }

    // MARK: - Load Messages
    func loadMessages() {
        db.collection("chatRooms")
            .document(chatRoomId)           // ← Load only THIS room's messages
            .collection("messages")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error fetching messages: \(error)")
                    return
                }
                
                self.messages = snapshot?.documents.compactMap { doc in
                    let data = doc.data()
                    guard let id = data["id"] as? String,
                          let text = data["text"] as? String,
                          let senderId = data["senderId"] as? String,
                          let senderName = data["senderName"] as? String,
                          let timestamp = data["timestamp"] as? Timestamp else {
                        return nil
                    }
                    
                    return Message(
                        id: id,
                        text: text,
                        senderId: senderId,
                        senderName: senderName,
                        timestamp: timestamp.dateValue()
                    )
                } ?? []
            }
    }
    
    // MARK: - FaceTime Functions
    func requestFaceTimeCall() {
        showFaceTimeConfirmation = true
    }
    
    func openFaceTime() {
        // Clean the contact (remove spaces, dashes, parentheses)
        let cleanedContact = recipientContact
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")
        
        // Create FaceTime URL
        guard let url = URL(string: "facetime://\(cleanedContact)") else {
            alertMessage = "Invalid contact information"
            showFaceTimeAlert = true
            return
        }
        
        // Check if FaceTime is available
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url) { success in
                DispatchQueue.main.async {
                    if !success {
                        self.alertMessage = "Unable to open FaceTime"
                        self.showFaceTimeAlert = true
                    }
                }
            }
        } else {
            alertMessage = "FaceTime is not available on this device"
            showFaceTimeAlert = true
        }
    }
    
    // MARK: - Getter for Recipient Name (for View)
    func getRecipientName() -> String {
        return recipientName
    }
}
