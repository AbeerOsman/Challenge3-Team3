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
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.conversations) { conversation in
                                NavigationLink {
                                    LiveChatView(
                                        currentUserId: viewModel.deafUserId,
                                        currentUserName: viewModel.deafName,
                                        recipientUserId: conversation.translatorId,
                                        recipientName: conversation.translatorName,
                                        recipientContact: "0000000000"
                                    )
                                } label: {
                                    ConversationCard(conversation: conversation)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .padding(.bottom, 8)
                    }
                }
            }
            .environment(\.layoutDirection, .rightToLeft)
        }
        .navigationTitle("الرسائل")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .onAppear {
            viewModel.openChatWith = nil
        }
    }
}

// MARK: - Conversation Card Component
struct ConversationCard: View {
    let conversation: Conversation
    
    var body: some View {
        HStack(spacing: 14) {
            // Avatar with online indicator
            ZStack(alignment: .bottomTrailing) {
                Circle()
                    .fill(avatarGradient(for: conversation.gender))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Text(String(conversation.translatorName.prefix(1)))
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                    )
                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            }
            
            // Content
            VStack(alignment: .trailing, spacing: 6) {
                HStack(alignment: .top, spacing: 8) {
                    // Translator name
                    Text(conversation.translatorName)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(Color(hex: "1A1A1A"))
                        .lineLimit(1)
                    
                    Spacer()
                    
                    // Time stamp
                    Text(formattedTime(conversation.timestamp))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.gray.opacity(0.8))
                }
                
                // Last message
                Text(conversation.lastMessage)
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
                    .lineLimit(2)
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
        )
    }
    
    // MARK: - Time Formatter
    private func formattedTime(_ date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        
        if calendar.isDateInToday(date) {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            formatter.locale = Locale(identifier: "ar")
            return formatter.string(from: date)
        } else if calendar.isDateInYesterday(date) {
            return "أمس"
        } else if calendar.isDate(date, equalTo: now, toGranularity: .weekOfYear) {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE"
            formatter.locale = Locale(identifier: "ar")
            return formatter.string(from: date)
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM"
            formatter.locale = Locale(identifier: "ar")
            return formatter.string(from: date)
        }
    }
}

// MARK: - Avatar Gradient
private func avatarGradient(for gender: Any) -> LinearGradient {
    let genderEnum: Gender
    if let g = gender as? Gender {
        genderEnum = g
    } else if let gStr = gender as? String {
        let t = gStr.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if ["أنثى", "female", "f"].contains(t) {
            genderEnum = .female
        } else {
            genderEnum = .male
        }
    } else {
        genderEnum = .male
    }
    
    switch genderEnum {
    case .female:
        return LinearGradient(
            colors: [Color.pink.opacity(0.9), Color.pink],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    case .male:
        return LinearGradient(
            colors: [Color(hex: "0D189F"), Color(hex: "0A1280")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        MessagesView(viewModel: TranslationViewModel())
            .environment(\.layoutDirection, .rightToLeft)
    }
}
