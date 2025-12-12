import SwiftUI

struct MessagesView: View {
    @ObservedObject var viewModel: TranslationViewModel
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "F7F9FF"), Color(hex: "F2F6FF")]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // MARK: - Empty State
                if viewModel.conversations.isEmpty {
                    
                    Spacer()
                    
                    Image(systemName: "bubble.left.and.text.bubble.right")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 55, height: 55)
                        .foregroundColor(.gray.opacity(0.7))
                    
                    Text("لا توجد محادثات")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.gray)
                    
                    Text("ابدأ محادثة مع مترجم من الصفحة الرئيسية")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.top, 4)
                        .padding(.horizontal, 40)
                    
                    Spacer()
                    
                } else {
                    
                    // MARK: - List of message threads
                    List(viewModel.conversations) { conversation in
                        NavigationLink {
                            LiveChatView(
                                currentUserId: viewModel.deafUserId,
                                currentUserName: viewModel.deafName,
                                recipientUserId: conversation.translatorId,
                                recipientName: conversation.translatorName,
                                recipientContact: "0000000000"
                            )
                        } label: {
                            HStack(spacing: 12) {
                                
                                // Avatar
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color(hex: "0D189F"), Color(hex: "0A1280")],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 50, height: 50)
                                    .overlay(
                                        Text(String(conversation.translatorName.prefix(1)))
                                            .font(.system(size: 20, weight: .bold))
                                            .foregroundColor(.white)
                                    )
                                
                                VStack(alignment: .trailing, spacing: 4) {
                                    Text(conversation.translatorName)
                                        .font(.system(size: 16, weight: .semibold))
                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                    
                                    Text(conversation.lastMessage)
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                        .lineLimit(1)
                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                }
                                
                                Spacer()
                                
                                Text(formattedTime(conversation.timestamp))
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 8)
                        }
                        
                        .listRowBackground(Color.clear)
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)                }
            }
            .environment(\.layoutDirection, .rightToLeft)
        }
        .navigationTitle("الرسائل")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .onAppear {
            if viewModel.openChatWith != nil {
                viewModel.openChatWith = nil
            }
        }
    }
    
    // MARK: - Time Formatter
    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.doesRelativeDateFormatting = true
        formatter.locale = Locale(identifier: "ar")
        return formatter.string(from: date)
    }
}

#Preview {
    NavigationStack {
        MessagesView(viewModel: TranslationViewModel())
            .environment(\.layoutDirection, .rightToLeft)
    }
}
