//
//  DeafName.swift
//  Challenge3-Team3
//
//  Created by alya Alabdulrahim on 11/06/1447 AH.
//


import SwiftUI

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

                Text("Log in")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.black)

                // Name Input
                TextField("Name", text: $deafName)
                    .padding()
                    .frame(width: 350, height: 55)
                    .background(Color.white)
                    .cornerRadius(13)

                // Save button → saves to Firebase + navigates
                NavigationLink(destination: AllTranslatorsView()) {
                    Text("Save")
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
