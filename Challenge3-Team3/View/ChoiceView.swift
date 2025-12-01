//
//  ChoiceView.swift
//  Challenge3-Team3
//
//  Created by alya Alabdulrahim on 10/06/1447 AH.
//
import SwiftUI

// MARK: - Main View
struct ChoiceView: View {
    @StateObject private var viewModel = ChoiceViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("darkblue")
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Spacer(minLength: 60)
                    
                    ChoiceHeaderView()
                    
                    Spacer()
                    
                    ButtonsView(
                        offerAction: {
                            //   navigation
                            if let option = viewModel.options.first(where: { $0.type == .offerSupport }) {
                                viewModel.handleTap(on: option)
                            } else {
                                // Fallback: set directly
                                viewModel.selectedChoice = .offerSupport
                            }
                        },
                        needInterpreterAction: {
                            if let option = viewModel.options.first(where: { $0.type == .needInterpreter }) {
                                viewModel.handleTap(on: option)
                            } else {
                                viewModel.selectedChoice = .needInterpreter
                            }
                        }
                    )
                    
                    Spacer()
                }
                .padding()
            }
            //  enum to destinations
            .navigationDestination(item: $viewModel.selectedChoice, destination: { choice in
                switch choice {
                case .offerSupport:
                    TranslatorProfileView()
                case .needInterpreter:
                    AllTranslatorsView()
                }
            })
        }
    }
}

// MARK: - Header
struct ChoiceHeaderView: View {
    var body: some View {
        ZStack {
            Image("hands")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 380, maxHeight: 380)
                .offset(y: 80)
                .allowsHitTesting(false)
            
            Text("This is where signs are understood,\nvoices are heard,\nand the community connects.")
                .font(.title)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 320)
                .offset(y: -60)
        }
        .frame(maxWidth: .infinity, minHeight: 420)
        .padding(.horizontal)
    }
}

// MARK: - Buttons container
struct ButtonsView: View {
    let offerAction: () -> Void
    let needInterpreterAction: () -> Void
    
    var body: some View {
        HStack(spacing: 20) {
            ChoiceButton(
                title: "I want to offer\nsupport",
                action: offerAction
            )
            
            ChoiceButton(
                title: "I need a sign\nlanguage interpreter",
                action: needInterpreterAction
            )
        }
        .padding(.horizontal)
    }
}

// MARK: - Choice Button Component
struct ChoiceButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.title3)
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .frame(height: 200)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.white.opacity(0.9))
                        .shadow(radius: 20)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(Color.white, lineWidth: 3)
                )
        }
    }
}

// MARK: - Preview
struct ChoiceView_Previews: PreviewProvider {
    static var previews: some View {
        ChoiceView()
    }
}

