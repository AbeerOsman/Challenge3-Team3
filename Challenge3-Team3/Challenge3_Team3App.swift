    
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
//                .environmentObject(translationViewModel) // ✨ Share with all views
            AppContainer()
        }
    }
}
