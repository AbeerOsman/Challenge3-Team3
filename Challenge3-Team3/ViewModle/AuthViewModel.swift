import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

final class AuthViewModel: ObservableObject {
    @Published var user: User?
    @Published var userRole: String?        // "interpreter" or "requester"

    private let db = Firestore.firestore()
    
    // Key for storing user choice locally
    private let roleStorageKey = "userRole"

    init() {
        user = Auth.auth().currentUser
        
        // Load saved role from UserDefaults
        userRole = UserDefaults.standard.string(forKey: roleStorageKey)

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

    // MARK: - Save role (interpreter / requester)
    func saveRole(for choice: ChoiceType) {
        guard let uid = user?.uid else { return }

        let role: String
        switch choice {
        case .offerSupport:
            role = "interpreter"
        case .needInterpreter:
            role = "requester"
        }

        // Save to UserDefaults for quick local access
        UserDefaults.standard.set(role, forKey: roleStorageKey)
        DispatchQueue.main.async {
            self.userRole = role
        }

        // Also save to Firestore (users collection)
        db.collection("users")
            .document(uid)
            .setData(["role": role], merge: true) { error in
                if let error = error {
                    print("Failed to save role: \(error.localizedDescription)")
                }
            }
    }

    // MARK: - Create deaf user profile (deafUsers collection)
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
    
    // MARK: - Delete deaf account ONLY from deafUsers
    func deleteDeafAccount(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let uid = user?.uid else {
            print("❌ No Firebase user UID – cannot delete deaf account")
            completion(.failure(NSError(domain: "AuthViewModel",
                                        code: -1,
                                        userInfo: [NSLocalizedDescriptionKey: "Missing user id"])))
            return
        }

        db.collection("deafUsers")
            .document(uid)
            .delete { error in
                if let error = error {
                    print("❌ Failed to delete deaf user profile: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }

                print("✅ Deaf user profile deleted from deafUsers")
                // Optional: clear local role
                self.clearRole()
                completion(.success(()))
            }
    }
    
    // MARK: - Helpers
    
    // Check if user has already made a choice
    func hasUserMadeChoice() -> Bool {
        return userRole != nil
    }
    
    // Clear saved role (for logout / delete)
    func clearRole() {
        UserDefaults.standard.removeObject(forKey: roleStorageKey)
        DispatchQueue.main.async {
            self.userRole = nil
        }
    }
}
