    
import SwiftUI
import FirebaseCore

@main
struct Challenge3_Team3App: App {
    @StateObject private var translationViewModel = TranslationViewModel() // ✨ Create once here
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
//            splash()
//            LiveChatView(
//                currentUserId: "user123",
//                currentUserName: "Me",
//                recipientUserId: "user456",
//                recipientName: "John Doe",
//                recipientContact: "1234567890"
//            )

//                .environmentObject(translationViewModel) // ✨ Share with all views
            AppContainer()
        }
    }
}
