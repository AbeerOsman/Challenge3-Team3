

import SwiftUI

struct TranslatorMessagesView: View {
    var body: some View {
        NavigationView {
            ZStack{
                LinearGradient(gradient: Gradient(colors: [Color(hex: "F7F9FF"), Color(hex: "F2F6FF")]),
                               startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
                VStack {
                    Spacer()
                    
                    VStack(spacing: 12) {
                        Image(systemName: "bubble.left.and.text.bubble.right")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 55, height: 55)
                            .foregroundColor(.gray.opacity(0.7))
                        
                        Text("No messages available")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .navigationTitle("Messages")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}

#Preview {
    TranslatorMessagesView()
}
