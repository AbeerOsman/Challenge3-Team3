//
//  LiveChatModel.swift
//  Challenge3-Team3
//
//  Created by Eatzaz Hafiz on 02/12/2025.
//

import Foundation
import FirebaseFirestore

struct Message: Identifiable, Codable {
    let id: String
    let text: String
    let senderId: String      // ← Who sent it
    let senderName: String    // ← Sender's name
    let timestamp: Date
    
    init(id: String = UUID().uuidString,
         text: String,
         senderId: String,
         senderName: String,
         timestamp: Date = Date()) {
        self.id = id
        self.text = text
        self.senderId = senderId
        self.senderName = senderName
        self.timestamp = timestamp
    }
}

// MARK: - Firestore Helpers
extension Message {
    // Convert Message to Firestore dictionary
    func toDictionary() -> [String: Any] {
        return [
            "id": id,
            "text": text,
            "senderId": senderId,
            "senderName": senderName,
            "timestamp": Timestamp(date: timestamp)
        ]
    }
    
    // Create Message from Firestore document
    static func fromDictionary(_ data: [String: Any]) -> Message? {
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
    }
}
