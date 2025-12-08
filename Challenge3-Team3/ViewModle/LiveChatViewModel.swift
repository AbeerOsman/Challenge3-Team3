//
//  LiveChatViewModel.swift
//  Challenge3-Team3
//
//  Created by Eatzaz Hafiz on 02/12/2025.
//

import SwiftUI
import FirebaseFirestore
import Combine
import UserNotifications
import AuthenticationServices

class LiveChatViewModel: ObservableObject {
    
    @Published var messages: [Message] = []
    @Published var messageText: String = ""
    
    // FaceTime states
    @Published var showFaceTimeConfirmation = false
    @Published var showFaceTimeAlert = false
    @Published var alertMessage = ""

    // NEW: Apple login sheet
    @Published var showAppleLoginSheet = false
    
    private let db = Firestore.firestore()
    private let currentUserId: String
    private let currentUserName: String
    private let recipientUserId: String
    private let recipientName: String
    private let recipientContact: String
    private let chatRoomId: String
    
    private var lastMessageCount = 0
    
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
        
        self.chatRoomId = [currentUserId, recipientUserId]
            .sorted()
            .joined(separator: "_")
        
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
        
        db.collection("chatRooms")
            .document(chatRoomId)
            .collection("messages")
            .document(msg.id)
            .setData(data)
        
        messageText = ""
    }

    func loadMessages() {
        db.collection("chatRooms")
            .document(chatRoomId)
            .collection("messages")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { [weak self] snapshot, _ in
                guard let self = self else { return }
                
                let newMessages = snapshot?.documents.compactMap { doc -> Message? in
                    let data = doc.data()
                    
                    guard let id = data["id"] as? String,
                          let text = data["text"] as? String,
                          let senderId = data["senderId"] as? String,
                          let senderName = data["senderName"] as? String,
                          let timestamp = data["timestamp"] as? Timestamp else { return nil }
                    
                    return Message(
                        id: id,
                        text: text,
                        senderId: senderId,
                        senderName: senderName,
                        timestamp: timestamp.dateValue()
                    )
                } ?? []
                
                if newMessages.count > self.lastMessageCount,
                   let latest = newMessages.last,
                   latest.senderId == self.recipientUserId {
                    self.notifyNewMessage(from: latest.senderName, messageText: latest.text)
                }
                
                self.messages = newMessages
                self.lastMessageCount = newMessages.count
            }
    }
    
    func requestFaceTimeCall() {
        showFaceTimeConfirmation = true
    }
    
    func openFaceTime() {
        let cleaned = recipientContact
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
    
    func getRecipientName() -> String {
        recipientName
    }
}
