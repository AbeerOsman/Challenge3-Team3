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
    let isUser: Bool
    let timestamp: Date
    
    init(id: String = UUID().uuidString,
         text: String,
         isUser: Bool,
         timestamp: Date = Date()) {
        self.id = id
        self.text = text
        self.isUser = isUser
        self.timestamp = timestamp
    }
}

