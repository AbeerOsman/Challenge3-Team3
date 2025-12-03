//
//  DeafName.swift
//  Challenge3-Team3
//
//  Created by alya Alabdulrahim on 11/06/1447 AH.
//

import SwiftUI

// NEW: Sheet wrapper for DeafName
struct DeafNameSheet: View {
    @ObservedObject var authViewModel: AuthViewModel
    @Binding var navigateToDeafHome: Bool
    @Binding var isPresented: Bool
    @Binding var deafName: String
    
    var body: some View {
        ZStack {
            Color(hex: "DDE8FD")
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Spacer()
                
                HStack {
                    Text("Your Name:")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.black)
                }
                
                TextField("Name", text: $deafName)
                    .padding()
                    .frame(width: 350, height: 55)
                    .background(Color.white)
                    .cornerRadius(13)

                Button {
                    if !deafName.isEmpty {
                        print("🔵 Sign in button pressed")
                        print("   Name entered: '\(deafName)'")
                        
                        authViewModel.createDeafUserProfile(name: deafName)
                        isPresented = false
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            print("   ✅ Navigating to DeafHome with name: '\(deafName)'")
                            navigateToDeafHome = true
                        }
                    }
                } label: {
                    Text("Save")
                        .foregroundColor(.white)
                        .frame(width: 350, height: 55)
                        .background(deafName.isEmpty ? Color.gray : Color(hex: "0D189F"))
                        .cornerRadius(13)
                }
                .disabled(deafName.isEmpty)

                Spacer()
            }
            .padding()
        }
    }
}

// MARK: - Original DeafName view (keep for compatibility)
struct DeafName: View {
    @ObservedObject var authViewModel: AuthViewModel
    @State private var deafName: String = ""

    var body: some View {
        ZStack {
            // Background
            Color(hex: "DDE8FD")
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Spacer()
                
                Text("Sign in")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.black)
                Spacer()
                // Name Input
                TextField("Name", text: $deafName)
                    .padding()
                    .frame(width: 350, height: 55)
                    .background(Color.white)
                    .cornerRadius(13)

                // Save button → saves to Firebase + navigates
                NavigationLink(destination: DeafHome( deafName: $deafName)) {
                    Text("Sign in")
                        .foregroundColor(.white)
                        .frame(width: 350, height: 55)
                        .background(Color(hex: "0D189F"))
                        .cornerRadius(13)
                }
                .disabled(deafName.isEmpty)
                .simultaneousGesture(
                    TapGesture().onEnded {
                        if !deafName.isEmpty {
                            authViewModel.createDeafUserProfile(name: deafName)
                        }
                    }
                )

                Spacer()
            }
            .padding()
            .background(Color(hex: "DDE8FD"))
            .cornerRadius(25)
            .padding(.horizontal, 40)
        }
    }
}

#Preview {
    DeafName(authViewModel: AuthViewModel())
}

