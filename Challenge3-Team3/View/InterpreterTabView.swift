import SwiftUI

struct InterpreterTabView: View {
    @EnvironmentObject private var appStateManager: AppStateManager
    @EnvironmentObject private var authViewModel: AuthViewModel
    @StateObject private var viewModel = TranslationViewModel()
    
    var body: some View {
        TabView {
            // Profile Tab
            MainTranslatorProfileView()
                .tabItem {
                    Image(systemName: "person.crop.circle")
                    Text("الملف الشخصي")
                }

            // Messages Tab
            MessagesView(viewModel: viewModel)
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
