//
//  LiveChatView.swift
//  Challenge3-Team3
//
//  Created by Eatzaz Hafiz on 02/12/2025.
//

import SwiftUI
import AuthenticationServices

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
            messagesList
            bottomInputBar
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack {
                    Text(recipientName)
                        .font(.system(size: 16))
                    
                    Image(systemName: "person.crop.circle.fill")
                        .foregroundColor(.primary1)
                        .font(.system(size: 30))
                }
            }
        }
        .padding(20)
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
        
        // MARK: - Apple Login Sheet
        .sheet(isPresented: $viewModel.showAppleLoginSheet) {
            VStack(spacing: 20) {

                Text("Use FaceTime?")
                    .font(.title2)
                    .bold()
                    .padding(.top, 30)

                Text("Sign in with your Apple ID to start a FaceTime video call.")
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                SignInWithAppleButton(.signIn, onRequest: { request in
                    request.requestedScopes = [.email, .fullName]
                }, onCompletion: { result in
                    switch result {
                    case .success(_):
                        viewModel.showAppleLoginSheet = false
                        viewModel.requestFaceTimeCall()
                    case .failure(let error):
                        print("Apple sign in failed:", error.localizedDescription)
                    }
                })
                .signInWithAppleButtonStyle(.black)
                .frame(height: 50)
                .cornerRadius(10)
                .padding(.horizontal, 40)

                Button("Not Now") {
                    viewModel.showAppleLoginSheet = false
                }
                .padding(.bottom, 30)

                Spacer()
            }
            .presentationDetents([.height(350)])
        }
    }
    
    // MARK: - Messages List Component
    private var messagesList: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(viewModel.messages) { message in
                    HStack {
                        if message.senderId == currentUserId {
                            Spacer()
                        }
                        
                        VStack(
                            alignment: message.senderId == currentUserId ? .trailing : .leading,
                            spacing: 4
                        ) {
                            Text(message.text)
                                .padding(12)
                                .background(message.senderId == currentUserId ? Color.darkblue : Color.gray.opacity(0.2))
                                .foregroundColor(message.senderId == currentUserId ? .white : .primary)
                                .cornerRadius(16)
                            
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
            // Updated video button
            Button {
                viewModel.showAppleLoginSheet = true
            } label: {
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
    NavigationStack {
        LiveChatView(
            currentUserId: "user123",
            currentUserName: "Me",
            recipientUserId: "user456",
            recipientName: "John Doe",
            recipientContact: "+966501234567"
        )
    }
}
