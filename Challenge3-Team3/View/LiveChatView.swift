//
//  LiveChatView.swift
//  Challenge3-Team3
//
//  Created by Eatzaz Hafiz on 02/12/2025.
//

import SwiftUI


struct LiveChatView: View {
    
    @StateObject var viewModel = LiveChatViewModel()
    
    
    var body: some View {
        VStack {

            // MARK: - Top Bar
            ZStack {
                Rectangle()
                    .fill(Color.white.opacity(0.1))
                    .frame(height: 60)

                HStack {
                    Button(action: {}) {
                        HStack {
                            Image(systemName: "chevron.backward")
                                .font(.system(size: 20))
                            Text("Back")
                        }
                        .foregroundColor(.darkblue)
                    }

                    Spacer()
                    Text("User Name")
                                           .font(.system(size: 16))
                    Image(systemName: "person.crop.circle.fill")
                        .foregroundColor(.primary1)
                        .font(.system(size: 30))
                        .padding(.leading, 16)
                   
                    
                    
                }
                .padding(.horizontal)
            }
            
            // MARK: - Messages List 
                        ScrollView {
                            VStack(spacing: 12) {
                                ForEach(viewModel.messages) { message in
                                    HStack {
                                        if message.isUser { Spacer() }
                                        
                                        Text(message.text)
                                            .padding(12)
                                            .background(message.isUser ? Color.darkblue : Color.gray.opacity(0.2))
                                            .foregroundColor(message.isUser ? .white : .primary)
                                            .cornerRadius(16)
                                        
                                        if !message.isUser { Spacer() }
                                    }
                                }
                            }
                            .padding()
                        }

            Spacer()

            // MARK: - Bottom Input Bar
            HStack {
                Button(action: {}) {
                        Image(systemName: "video")
                            .foregroundColor(.darkblue)
                            .font(.system(size: 23))
                }

                HStack {
                    TextField("Text Message", text: $viewModel.messageText)
                        .font(.callout)
                        .foregroundColor(.gray)
                        .padding(.leading, 8)
                    
                    Button {
                            viewModel.sendMessage()   // ← SENDS THE MESSAGE
                        } label: {
                            Image(systemName: "paperplane.fill")
                                .foregroundColor(.darkblue)
                                .font(.system(size: 20))
                        }
//                        .onSubmit {
//                                viewModel.sendMessage()   // ← triggers when pressing "Return"
//                            }

                    Spacer()
                }
                .frame(width:334,height: 40)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.darkblue)
                )
            }
            .padding(.horizontal)
        }
        .padding(20)
    }
}

#Preview {
    LiveChatView()
}
