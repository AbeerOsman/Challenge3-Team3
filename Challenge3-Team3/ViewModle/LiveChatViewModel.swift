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
    
    init() {
        loadMessages()
    }
    
    // Send text func
    func sendMessage() {
        guard !messageText.isEmpty else { return }
        
        let msg = Message (text: messageText, isUser: true)
        
        do {
                    try db.collection("chats")
                        .document(msg.id)
                        .setData(from: msg)
                } catch {
                    print("Error sending message: \(error)")
                }

                messageText = ""
        }
    
    // Real-time listener func
    func loadMessages() {
            db.collection("chats")
                .order(by: "timestamp", descending: false)
                .addSnapshotListener { snapshot, error in
                    if let error = error {
                        print("Error fetching messages: \(error)")
                        return
                    }

                    self.messages = snapshot?.documents.compactMap { doc in
                        try? doc.data(as: Message.self)
                    } ?? []
                }
        }
        
    
}

    
