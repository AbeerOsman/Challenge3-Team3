import SwiftUI
import AuthenticationServices

struct TranslatorLiveChatView: View {
    @StateObject var viewModel: TranslatorLiveChatViewModel
    @Environment(\.dismiss) var dismiss
    
    let currentUserId: String
    let currentUserName: String
    let recipientUserId: String
    let recipientName: String
    let chatRoomId: String
    
    init(currentUserId: String,
         currentUserName: String,
         recipientUserId: String,
         recipientName: String,
         chatRoomId: String) {
        
        self.currentUserId = currentUserId
        self.currentUserName = currentUserName
        self.recipientUserId = recipientUserId
        self.recipientName = recipientName
        self.chatRoomId = chatRoomId
        
        _viewModel = StateObject(wrappedValue: TranslatorLiveChatViewModel(
            currentUserId: currentUserId,
            currentUserName: currentUserName,
            recipientUserId: recipientUserId,
            recipientName: recipientName,
            chatRoomId: chatRoomId
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
                HStack(spacing: 8) {
                    Circle()
                        .fill(Color.darkblue)
                        .frame(width: 36, height: 36)
                        .overlay(
                            Text(String(recipientName.prefix(1)))
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                        )

                    Text(recipientName)
                        .font(.system(size: 17, weight: .bold))
                }
            }
        }
        .padding(20)
        .alert("FaceTime", isPresented: $viewModel.showFaceTimeAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.alertMessage)
        }
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
        .onAppear {
            FirebaseService.shared.debugCheckMessages(chatRoomId: chatRoomId)
        }
    }
    
    private var bottomInputBar: some View {
        HStack {
            Button {
                viewModel.showAppleLoginSheet = true
            } label: {
                Image(systemName: "video.fill")
                    .foregroundColor(.darkblue)
                    .font(.system(size: 23))
            }

            HStack {
                TextField("اكتب رسالة...", text: $viewModel.messageText)
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
        TranslatorLiveChatView(
            currentUserId: "translator1",
            currentUserName: "المترجم",
            recipientUserId: "deaf1",
            recipientName: "المستخدم",
            chatRoomId: "deaf1_translator1"
        )
        .environment(\.layoutDirection, .rightToLeft)
    }
}
