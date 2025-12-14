import SwiftUI

struct InterpreterTabView: View {
    @EnvironmentObject private var appStateManager: AppStateManager
    @EnvironmentObject private var authViewModel: AuthViewModel
    
    var body: some View {
        TabView {
            // Profile Tab
            MainTranslatorProfileView()
                .tabItem {
                    Image(systemName: "person.crop.circle")
                    Text("الملف الشخصي")
                }

            // Messages Tab - Use TranslatorMessagesView instead of MessagesView
            TranslatorMessagesView()
                .tabItem {
                    Image(systemName: "bubble.left.and.bubble.right")
                    Text("الرسائل")
                }
        }
        .tint(Color("darkblue"))
        .environment(\.layoutDirection, .rightToLeft)
    }
}

#Preview {
    InterpreterTabView()
        .environmentObject(AppStateManager())
        .environmentObject(AuthViewModel())
        .environment(\.layoutDirection, .rightToLeft)
}
