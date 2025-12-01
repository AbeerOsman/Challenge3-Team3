//
//  SplashView.swift
//  Challenge3-Team3
//
//  Created by alya Alabdulrahim on 10/06/1447 AH.
//

import SwiftUI

struct splash: View {
    @State private var goNext = false
    @State private var animate = false
    
    var body: some View {
        ZStack {
            Color("darkblue").ignoresSafeArea()
              
            Image("deaf_icon")
                .resizable()
                .scaledToFit()
                .frame(width: 400)
                // Removed foregroundColor to prevent tinting to white
                .scaleEffect(animate ? 1.1 : 0.7)
                .opacity(animate ? 1 : 0)
                .animation(.easeInOut(duration: 1.4), value: animate)
        }
        .onAppear {
            animate = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                goNext = true
            }
        }
        .fullScreenCover(isPresented: $goNext) {
            ChoiceView()
        }
    }
}

#Preview {
    splash()
}
