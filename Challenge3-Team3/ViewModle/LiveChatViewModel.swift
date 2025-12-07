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
    
    private let db = Firestore.firestore()
    private let currentUserId: String      // ← Current user's ID
    private let currentUserName: String    // ← Current user's name
    private let recipientUserId: String    // ← Other user's ID
    private let chatRoomId: String         // ← Unique chat room ID
    
    init(currentUserId: String,
         currentUserName: String,
         recipientUserId: String) {
        self.currentUserId = currentUserId
        self.currentUserName = currentUserName
        self.recipientUserId = recipientUserId
        
        // Create unique chat room ID (alphabetically sorted so it's the same for both users)
        self.chatRoomId = [currentUserId, recipientUserId]
            .sorted()
            .joined(separator: "_")
        
        loadMessages()
    }

    // Send text func
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

    // Real-time listener func
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
    
}

    
