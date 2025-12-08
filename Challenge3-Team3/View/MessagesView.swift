import SwiftUI

struct MessageThread: Identifiable {
    let id = UUID().uuidString
    let userId: String
    let userName: String
    let lastMessage: String
    let time: String
}

struct MessagesView: View {
    
    // Dummy Conversations
    let dummyThreads: [MessageThread] = [
        MessageThread(
            userId: "user001",
            userName: "Sarah Ahmed",
            lastMessage: "Thank you so much!",
            time: "10:24 AM"
        ),
        MessageThread(
            userId: "user002",
            userName: "Mohammed Ali",
            lastMessage: "When can we start?",
            time: "Yesterday"
        ),
        MessageThread(
            userId: "user003",
            userName: "Aisha Saleh",
            lastMessage: "Sure, I understand.",
            time: "Mon"
        )
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                
                if dummyThreads.isEmpty {
                    
                    Spacer()
                    
                    Image(systemName: "bubble.left.and.text.bubble.right")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 55, height: 55)
                        .foregroundColor(.gray.opacity(0.7))
                    
                    Text("No messages available")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                } else {
                    
                    List(dummyThreads) { thread in
                        NavigationLink {
                            
                            LiveChatView(
                                currentUserId: "currentUser123",
                                currentUserName: "Me",
                                recipientUserId: thread.userId,
                                recipientName: thread.userName,
                                recipientContact: "0000000000"
                            )
                            
                        } label: {
                            HStack(spacing: 12) {
                                
                                Image(systemName: "person.crop.circle.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.blue.opacity(0.8))
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(thread.userName)
                                        .font(.system(size: 16, weight: .semibold))
                                    
                                    Text(thread.lastMessage)
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                Text(thread.time)
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 8)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Messages")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    MessagesView()
}
