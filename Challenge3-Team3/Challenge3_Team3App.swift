import SwiftUI
import FirebaseCore

@main
struct Challenge3_Team3App: App {
    @StateObject private var translationViewModel = TranslationViewModel()
    @StateObject private var authViewModel = AuthViewModel()      // ✅ new shared auth VM

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            AppContainer()
                .environmentObject(translationViewModel)
                .environmentObject(authViewModel)                 // ✅ inject into environment
        }
    }
}
