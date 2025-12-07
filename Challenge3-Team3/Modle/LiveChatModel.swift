//
//  LiveChatModel.swift
//  Challenge3-Team3
//
//  Created by Eatzaz Hafiz on 02/12/2025.
//

import Foundation

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
