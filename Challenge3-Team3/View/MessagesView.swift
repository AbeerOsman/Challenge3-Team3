import SwiftUI

struct MessagesView: View {
    
    // Dummy conversations using the SAME fields as Message model
    let dummyMessages: [Message] = [
        Message(
            text: "Thank you so much!",
            senderId: "user001",
            senderName: "Sarah Ahmed",
            timestamp: Date()
        ),
        Message(
            text: "When can we start?",
            senderId: "user002",
            senderName: "Mohammed Ali",
            timestamp: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
        ),
        Message(
            text: "Sure, I understand.",
            senderId: "user003",
            senderName: "Aisha Saleh",
            timestamp: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date()
        )
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            
            // MARK: - Header
            HStack {
                Text("Messages")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.black)
                Spacer()
            }
            .padding()
            
            Divider()
            
            // MARK: - Empty State
            if dummyMessages.isEmpty {
                
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
                
                // MARK: - List of message threads
                List(dummyMessages) { message in
                    NavigationLink {
                        LiveChatView(
                            currentUserId: "currentUser123",
                            currentUserName: "Me",
                            recipientUserId: message.senderId,
                            recipientName: message.senderName,
                            recipientContact: "0000000000"
                        )
                    } label: {
                        HStack(spacing: 12) {
                            
                            Image(systemName: "person.crop.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.primary1)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(message.senderName)
                                    .font(.system(size: 16, weight: .semibold))
                                
                                Text(message.text)
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                                    .lineLimit(1)
                            }
                            
                            Spacer()
                            
                            Text(formattedTime(message.timestamp))
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 8)
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationBarBackButtonHidden(false)
    }
    
    // MARK: - Time Formatter
    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.doesRelativeDateFormatting = true
        return formatter.string(from: date)
    }
}

#Preview {
    NavigationStack {
        MessagesView()
    }
}
