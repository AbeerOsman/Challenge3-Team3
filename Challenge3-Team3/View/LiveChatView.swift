//
//  LiveChatView.swift
//  Challenge3-Team3
//
//  Created by Eatzaz Hafiz on 02/12/2025.
//

import SwiftUI


struct LiveChatView: View {
    
    @StateObject var viewModel: LiveChatViewModel
    
    let currentUserId: String
        let currentUserName: String
        let recipientUserId: String
        let recipientName: String
        let recipientContact: String
    
    
    // Custom initializer
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
        
        // Initialize ViewModel with user IDs
        _viewModel = StateObject(wrappedValue: LiveChatViewModel(
            currentUserId: currentUserId,
            currentUserName: currentUserName,
            recipientUserId: recipientUserId
        ))
    }

    
    var body: some View {
        VStack {

            // MARK: - Top Bar
            ZStack {
                Rectangle()
                    .fill(Color.white.opacity(0.1))
                    .frame(height: 60)

                HStack {
                    Button(action: {}) {
                        HStack {
                            Image(systemName: "chevron.backward")
                                .font(.system(size: 20))
                            Text("Back")
                        }
                        .foregroundColor(.darkblue)
                    }

                    Spacer()
                    Text("User Name")
                                           .font(.system(size: 16))
                    Image(systemName: "person.crop.circle.fill")
                        .foregroundColor(.primary1)
                        .font(.system(size: 30))
                        .padding(.leading, 16)
                   
                    
                    
                }
                .padding(.horizontal)
            }
            
            // MARK: - Messages List 
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(viewModel.messages) { message in
                        HStack {
                            // Check if message is from current user
                            if message.senderId == currentUserId {
                                Spacer()
                            }
                            
                            VStack(alignment: message.senderId == currentUserId ? .trailing : .leading, spacing: 4) {
                                Text(message.text)
                                    .padding(12)
                                    .background(message.senderId == currentUserId ? Color.darkblue : Color.gray.opacity(0.2))
                                    .foregroundColor(message.senderId == currentUserId ? .white : .primary)
                                    .cornerRadius(16)
                                
                                // Show sender name if not current user
                                if message.senderId != currentUserId {
                                    Text(message.senderName)
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            if message.senderId != currentUserId {
                                Spacer()
                            }
                        }
                    }
                }
                .padding()
            }
            

            // MARK: - Bottom Input Bar
            HStack {
                Button(action: {}) {
                        Image(systemName: "video")
                            .foregroundColor(.darkblue)
                            .font(.system(size: 23))
                }

                HStack {
                    TextField("Text Message", text: $viewModel.messageText)
                        .font(.callout)
                        .foregroundColor(.gray)
                        .padding(.leading, 8)
                    
                    Button {
                            viewModel.sendMessage()   // ← SENDS THE MESSAGE
                        } label: {
                            Image(systemName: "paperplane.fill")
                                .foregroundColor(.darkblue)
                                .font(.system(size: 20))
                        }
//                        .onSubmit {
//                                viewModel.sendMessage()   // ← triggers when pressing "Return"
//                            }

                    Spacer()
                }
                .frame(width:334,height: 40)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.darkblue)
                )
            }
            .padding(.horizontal)
        }
        .padding(20)
    }
}

#Preview {
    LiveChatView(
        currentUserId: "user123",
        currentUserName: "Me",
        recipientUserId: "user456",
        recipientName: "John Doe",
        recipientContact: "1234567890"
    )
}
