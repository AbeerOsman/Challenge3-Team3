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
    @State private var showDeafNameSheet = false // NEW
    @State private var navigateToDeafHome = false // NEW
    @State private var deafName: String = ""

    

    var body: some View {
        NavigationStack {
            ZStack {
                Color("darkblue")
                    .ignoresSafeArea()

                VStack(spacing: 20) {
                    Spacer(minLength: 200)

                    ChoiceHeaderView()

                    ButtonsView(
                        options: choiceViewModel.options,
                        authViewModel: authViewModel,
                        showDeafNameSheet: $showDeafNameSheet, // NEW
                        onSelection: { option in
                            choiceViewModel.handleTap(on: option)
                            authViewModel.saveRole(for: option.type)
                        }
                    )
                    .padding(.bottom, 300)
                }
                .padding()
                
                // NavigationLink for DeafHome
                NavigationLink(destination: DeafHome(deafName: $deafName), isActive: $navigateToDeafHome) {
                    EmptyView()
                }
                
            }
            .navigationBarBackButtonHidden(true)
            .sheet(isPresented: $showDeafNameSheet) { // NEW: Sheet for DeafName
                DeafNameSheet(
                    authViewModel: authViewModel,
                    navigateToDeafHome: $navigateToDeafHome,
                    isPresented: $showDeafNameSheet,
                    deafName: $deafName
                )
                
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.hidden)
            }
        }
    }
}

// MARK: - Header
struct ChoiceHeaderView: View {
    var body: some View {
        ZStack {
           
            Text("This is where signs are understood,\nvoices are heard,\nand the community connects.")
                .font(.system(size: 30))
                .bold()
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 320)
                //.offset(y: -40)
            
//            Image("hands")
//                .resizable()
//                .scaledToFit()
//                .frame(maxWidth: 380, maxHeight: 380)
//                .offset(y: 120)
//                .allowsHitTesting(false)
            
        }
        .frame(maxWidth: .infinity, minHeight: 420)
        .padding(.horizontal)
    }
}

// MARK: - Buttons container
struct ButtonsView: View {
    let options: [ChoiceOption]
    let authViewModel: AuthViewModel
    @Binding var showDeafNameSheet: Bool // NEW
    let onSelection: (ChoiceOption) -> Void

    var body: some View {
        HStack(spacing: 20) {
            ForEach(options) { option in
                // Check if this is "Need Interpreter" option
                if option.type == .needInterpreter {
                    // NEW: Show sheet instead of navigation
                    Button {
                        onSelection(option)
                        showDeafNameSheet = true
                    } label: {
                        ChoiceButton(title: option.title)
                    }
                } else {
                    // Keep NavigationLink for "Offer Support"
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
        }
        .padding(.horizontal)
    }

    @ViewBuilder
    private func destination(for type: ChoiceType) -> some View {
        switch type {
        case .offerSupport:
            TranslatorProfileView()
        case .needInterpreter:
            EmptyView() // Not used anymore
        }
    }
}

// MARK: - Choice Button Component
struct ChoiceButton: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.system(size: 20))
            .bold()
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
                    .stroke(Color.white, lineWidth: 6)
            )
    }
}

// MARK: - Preview
struct ChoiceView_Previews: PreviewProvider {
    static var previews: some View {
        ChoiceView()
    }
}
