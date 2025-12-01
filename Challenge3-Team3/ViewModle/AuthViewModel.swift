//
//  AuthViewModel.swift
//  Challenge3-Team3
//
//  Created by alya Alabdulrahim on 10/06/1447 AH.
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore



// every device signs in anonymously the first time and gets a UID.

enum UserRole: String {
    case interpreter       // offers support
    case requester         // needs interpreter
}

final class AuthViewModel: ObservableObject {
    @Published var user: User?

    private let db = Firestore.firestore()

    init() {
        user = Auth.auth().currentUser
        
        // Anonymous sign-in on startup if needed
        if user == nil {
            signInAnonymously()
        }
    }

    private func signInAnonymously() {
        Auth.auth().signInAnonymously { [weak self] result, error in
            if let error = error {
                print("Anonymous sign-in failed: \(error.localizedDescription)")
                return
            }
            guard let user = result?.user else { return }
            DispatchQueue.main.async {
                self?.user = user
            }
        }
    }

    func saveRole(for choice: ChoiceType) {
        let role: UserRole = (choice == .offerSupport) ? .interpreter : .requester

        guard let uid = user?.uid else {
            print("No user UID yet")
            return
        }

        db.collection("users")
            .document(uid)
            .setData(
                ["role": role.rawValue],
                merge: true
            ) { error in
                if let error = error {
                    print("Failed to save role: \(error.localizedDescription)")
                } else {
                    print("Role \(role.rawValue) saved for uid \(uid)")
                }
            }
    }
}
