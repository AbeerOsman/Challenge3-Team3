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

final class AuthViewModel: ObservableObject {
    @Published var user: User?

    private let db = Firestore.firestore()

    init() {
        user = Auth.auth().currentUser

        if user == nil {
            Auth.auth().signInAnonymously { [weak self] result, error in
                if let error = error {
                    print("Anonymous sign in failed: \(error.localizedDescription)")
                    return
                }

                guard let user = result?.user else { return }

                DispatchQueue.main.async {
                    self?.user = user
                }
            }
        }
    }

    func saveRole(for choice: ChoiceType) {
        guard let uid = user?.uid else { return }

        let role: String
        switch choice {
        case .offerSupport:
            role = "interpreter"
        case .needInterpreter:
            role = "requester"
        }

        db.collection("users")
            .document(uid)
            .setData(["role": role], merge: true) { error in
                if let error = error {
                    print("Failed to save role: \(error.localizedDescription)")
                }
            }
    }

    func createDeafUserProfile(name: String) {
        guard let uid = user?.uid else { return }

        db.collection("deafUsers")
            .document(uid)
            .setData(
                [
                    "name": name,
                    "createdAt": Timestamp(date: Date())
                ],
                merge: true
            ) { error in
                if let error = error {
                    print("Failed to save deaf user profile: \(error.localizedDescription)")
                } else {
                    print("Deaf user profile saved")
                }
            }
    }
}
