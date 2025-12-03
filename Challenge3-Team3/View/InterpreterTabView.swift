//
//  InterpreterTabView.swift
//  Challenge3-Team3
//
//  Created by alya Alabdulrahim on 12/06/1447 AH.
//

import SwiftUI

struct InterpreterTabView: View {
    var body: some View {
        TabView {

            // 1️⃣ Profile Tab
            TranslatorProfileView()
                .tabItem {
                    Image(systemName: "person.crop.circle")
                    Text("Profile")
                }

            // 2️⃣ Messages Tab
            MessagesView()
                .tabItem {
                    Image(systemName: "bubble.left.and.bubble.right")
                    Text("Messages")
                }

            // 3️⃣ Requests Tab
//            RequestsView()
//                .tabItem {
//                    Image(systemName: "bell.badge")
//                    Text("Requests")
//                }
        }
    }
}

#Preview {
    InterpreterTabView()
}
