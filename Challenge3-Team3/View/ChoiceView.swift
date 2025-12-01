//
//  ChoiceView.swift
//  Challenge3-Team3
//
//  Created by alya Alabdulrahim on 10/06/1447 AH.
//
import SwiftUI

// MARK: - Main View
struct ChoiceView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var choiceViewModel = ChoiceViewModel()

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
                        options: choiceViewModel.options,
                        onSelection: { option in
                            choiceViewModel.handleTap(on: option)
                            authViewModel.saveRole(for: option.type)
                        }
                    )
                    
                    Spacer()
                }
                .padding()
            }
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
    let options: [ChoiceOption]
    let onSelection: (ChoiceOption) -> Void
    
    var body: some View {
        HStack(spacing: 20) {
            ForEach(options) { option in
                NavigationLink {
                    destination(for: option.type)
                } label: {
                    ChoiceButton(title: option.title)
                }
                .simultaneousGesture(
                    TapGesture().onEnded {
                        onSelection(option)
                    }
                )
            }
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private func destination(for type: ChoiceType) -> some View {
        switch type {
        case .offerSupport:
            TranslatorProfileView()
        case .needInterpreter:
            AllTranslatorsView()
        }
    }
}

// MARK: - Choice Button Component
struct ChoiceButton: View {
    let title: String
    
    var body: some View {
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

// MARK: - Preview
struct ChoiceView_Previews: PreviewProvider {
    static var previews: some View {
        ChoiceView()
    }
}
