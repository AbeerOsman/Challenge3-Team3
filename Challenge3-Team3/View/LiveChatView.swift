//
//  LiveChatView.swift
//  Challenge3-Team3
//
//  Created by Eatzaz Hafiz on 02/12/2025.
//
import SwiftUI

struct LiveChatView: View {
    
    @StateObject var viewModel: LiveChatViewModel
    @Environment(\.dismiss) var dismiss
    
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
        
        // Initialize ViewModel with ALL parameters including FaceTime info
        _viewModel = StateObject(wrappedValue: LiveChatViewModel(
            currentUserId: currentUserId,
            currentUserName: currentUserName,
            recipientUserId: recipientUserId,
            recipientName: recipientName,
            recipientContact: recipientContact
        ))
    }

    var body: some View {
        VStack {
            // MARK: - Top Bar
            topBar
            
            // MARK: - Messages List
            messagesList
            
            // MARK: - Bottom Input Bar
            bottomInputBar
        }
        .padding(20)
        .navigationBarBackButtonHidden(true)   // ← hide system back, keep only custom
        .confirmationDialog(
            "Start FaceTime Call?",
            isPresented: $viewModel.showFaceTimeConfirmation,
            titleVisibility: .visible
        ) {
            Button("Call \(recipientName)") {
                viewModel.openFaceTime()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will open Apple FaceTime to start a video call with \(recipientName)")
        }
        .alert("FaceTime", isPresented: $viewModel.showFaceTimeAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.alertMessage)
        }
    }
    
    // MARK: - Top Bar Component
    private var topBar: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.backward")
                            .font(.system(size: 20))
                        Text("Back")
                    }
                    .foregroundColor(.darkblue)
                }

                Spacer()
                
                Text(recipientName)
                    .font(.system(size: 16))
                
                Image(systemName: "person.crop.circle.fill")
                    .foregroundColor(.primary1)
                    .font(.system(size: 30))
                    .padding(.leading, 8)
            }
            .padding(.horizontal)
            .frame(height: 60)
            
            // Line under the name / top bar
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: 1)
                .padding(.horizontal)
        }
        .background(Color.white.opacity(0.1))
    }
    
    // MARK: - Messages List Component
    private var messagesList: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(viewModel.messages) { message in
                    HStack {
                        // Check if message is from current user
                        if message.senderId == currentUserId {
                            Spacer()
                        }
                        
                        VStack(
                            alignment: message.senderId == currentUserId ? .trailing : .leading,
                            spacing: 4
                        ) {
                            Text(message.text)
                                .padding(12)
                                .background(
                                    message.senderId == currentUserId
                                    ? Color.darkblue
                                    : Color.gray.opacity(0.2)
                                )
                                .foregroundColor(
                                    message.senderId == currentUserId
                                    ? .white
                                    : .primary
                                )
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
    }
    
    // MARK: - Bottom Input Bar Component
    private var bottomInputBar: some View {
        HStack {
            // FaceTime Button
            Button(action: {
                viewModel.requestFaceTimeCall()
            }) {
                Image(systemName: "video.fill")
                    .foregroundColor(.darkblue)
                    .font(.system(size: 23))
            }

            HStack {
                TextField("Text Message", text: $viewModel.messageText)
                    .font(.callout)
                    .foregroundColor(.primary)
                    .accentColor(.darkblue)
                    .padding(.leading, 8)
                
                Button {
                    viewModel.sendMessage()
                } label: {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.darkblue)
                        .font(.system(size: 20))
                }

                Spacer()
            }
            .frame(width: 334, height: 40)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.darkblue)
            )
        }
        .padding(.horizontal)
    }
}

#Preview {
    LiveChatView(
        currentUserId: "user123",
        currentUserName: "Me",
        recipientUserId: "user456",
        recipientName: "John Doe",
        recipientContact: "+966501234567"
    )
}
