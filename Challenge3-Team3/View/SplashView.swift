//
//  SplashView.swift
//  Challenge3-Team3
//
//  Created by alya Alabdulrahim on 10/06/1447 AH.
//

//import SwiftUI
//
//
//
//struct splash: View {
//    @State private var goNext = false
//    @State private var animate = false
//    
//    var body: some View {
//        ZStack {
//            Color("darkblue").ignoresSafeArea()
//            Image("deaf_icon")
//                .resizable()
//                .scaledToFit()
//                .frame(width: 400)
//                .scaleEffect(animate ? 0.6 : 0.2)
//                .opacity(animate ? 1 : 0)
//                .animation(.easeInOut(duration: 1.4), value: animate)
//        }
//        .onAppear {
//            animate = true
//            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
//                presentChoiceViewController()
//            }
//        }
//    }
//    
//    private func presentChoiceViewController() {
//        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
//              let window = scene.windows.first,
//              let root = window.rootViewController else { return }
//        
//        let vc = UIHostingController(rootView: ChoiceView())
//        vc.modalPresentationStyle = .fullScreen
//        root.present(vc, animated: false, completion: nil) // animated: false -> no animation
//    }
//}
//
//
//#Preview {
//    splash()
//}

//
//  SplashView.swift
//  Challenge3-Team3
//
//  Created by alya Alabdulrahim on 10/06/1447 AH.
//

//
//  SplashView.swift
//  Challenge3-Team3
//

import SwiftUI

struct splash: View {
    @EnvironmentObject private var appStateManager: AppStateManager
    @State private var animate = false

    var body: some View {
        ZStack {
            Color("darkblue").ignoresSafeArea()

            Image("deaf_icon")
                .resizable()
                .renderingMode(.template)
                .foregroundColor(.white)
                .scaledToFit()
                .frame(width: 400)
                .scaleEffect(animate ? 40 : 0)
                .opacity(animate ? 100 : 100)
                .onAppear {
                    withAnimation(.easeInOut(duration: 1.4)) {
                        animate = true
                    }

                    // After splash animation, move to appropriate screen
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
                        appStateManager.moveToNextScreen()
                    }
                }
        }
    }
}

// MARK: - Preview
#Preview {
    splash()
        .environmentObject(AppStateManager())
}
