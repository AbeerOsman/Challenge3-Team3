import SwiftUI
import FirebaseAuth

struct TranslatorMessagesView: View {
    @StateObject private var viewModel = TranslatorMessagesViewModel()
    @EnvironmentObject private var authViewModel: AuthViewModel
    @Environment(\.layoutDirection) var layoutDirection
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "F7F9FF"), Color(hex: "F2F6FF")]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.conversations.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "bubble.left.and.text.bubble.right")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 55, height: 55)
                            .foregroundColor(.gray.opacity(0.7))
                        
                        Text("لا توجد رسائل")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                        
                        Text("ستظهر الرسائل من مستخدمي الصم هنا")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.conversations) { conversation in
                                NavigationLink {
                                    TranslatorLiveChatView(
                                        currentUserId: viewModel.translatorId,
                                        currentUserName: viewModel.translatorName,
                                        recipientUserId: conversation.deafUserId,
                                        recipientName: conversation.deafName,
                                        chatRoomId: conversation.chatRoomId
                                    )
                                } label: {
                                    TranslatorConversationCard(conversation: conversation)
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
            .navigationTitle("الرسائل")
            .navigationBarTitleDisplayMode(.inline)
        }
        .environment(\.layoutDirection, .rightToLeft)
        .onAppear {
            print("🔍 TranslatorMessagesView onAppear called")
            print("   Auth User: \(authViewModel.user?.uid ?? "NIL")")
            print("   Display Name: \(authViewModel.user?.displayName ?? "NIL")")
            
            // Get current Firebase user
            if let user = Auth.auth().currentUser {
                print("✅ Found current Firebase user: \(user.uid)")
                print("   Display Name: \(user.displayName ?? "No display name")")
                
                viewModel.setTranslator(
                    translatorId: user.uid,
                    translatorName: user.displayName ?? "المترجم"
                )
            } else {
                print("❌ No Firebase user found!")
            }
        }
    }
}

// MARK: - Translator Conversation Card
struct TranslatorConversationCard: View {
    let conversation: TranslatorConversation
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack(alignment: .bottomTrailing) {
                Circle()
                    .fill(avatarGradient(for: conversation.deafGender))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Text(String(conversation.deafName.prefix(1)))
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                    )
                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            }
            
            VStack(alignment: .trailing, spacing: 6) {
                HStack(alignment: .top, spacing: 8) {
                    Text(conversation.deafName)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(Color(hex: "1A1A1A"))
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Text(formattedTime(conversation.timestamp))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.gray.opacity(0.8))
                }
                
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
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM"
            formatter.locale = Locale(identifier: "ar")
            return formatter.string(from: date)
        }
    }
}

// MARK: - Avatar Gradient Helper
private func avatarGradient(for gender: String) -> LinearGradient {
    let genderLower = gender.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    
    if ["أنثى", "female", "f"].contains(genderLower) {
        return LinearGradient(
            colors: [Color.pink.opacity(0.9), Color.pink],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    } else {
        return LinearGradient(
            colors: [Color(hex: "0D189F"), Color(hex: "0A1280")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

#Preview {
    NavigationStack {
        TranslatorMessagesView()
            .environmentObject(AuthViewModel())
            .environment(\.layoutDirection, .rightToLeft)
    }
}
