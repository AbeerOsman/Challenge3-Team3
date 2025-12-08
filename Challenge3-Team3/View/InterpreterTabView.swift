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

            // Profile Tab
            TranslatorProfileView()
                .tabItem {
                    Image(systemName: "person.crop.circle")
                    Text("الملف الشخصي")
                }

            // Messages Tab
            MessagesView()
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
}
