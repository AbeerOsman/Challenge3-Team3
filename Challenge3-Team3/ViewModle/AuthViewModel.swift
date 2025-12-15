import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

final class AuthViewModel: ObservableObject {
    @Published var user: User?
    @Published var userRole: String?
    @Published var firebaseUID: String = ""  // ✅ NEW: Store the actual Firebase UID

    private let db = Firestore.firestore()
    
    private let roleStorageKey = "userRole"

    init() {
        user = Auth.auth().currentUser
        
        // ✅ NEW: Store Firebase UID when user is set
        if let user = user {
            self.firebaseUID = user.uid
            print("✅ AuthViewModel initialized with Firebase UID: \(user.uid)")
        }
        
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
                    // ✅ NEW: Store Firebase UID
                    self?.firebaseUID = user.uid
                    print("✅ Anonymous user created with Firebase UID: \(user.uid)")
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

        // ✅ FIXED: Save to Firestore with Firebase UID as document ID
        db.collection("users")
            .document(uid)  // ✅ Use Firebase UID as document ID
            .setData([
                "firebaseUID": uid,  // ✅ Also store as field for reference
                "role": role
            ], merge: true) { error in
                if let error = error {
                    print("Failed to save role: \(error.localizedDescription)")
                } else {
                    print("✅ Role saved successfully with Firebase UID: \(uid)")
                }
            }
    }

    // MARK: - Create deaf user profile (deafUsers collection)
    func createDeafUserProfile(name: String) {
        guard let uid = user?.uid else { return }

        db.collection("deafUsers")
            .document(uid)  // ✅ Use Firebase UID as document ID
            .setData(
                [
                    "firebaseUID": uid,  // ✅ Also store as field
                    "name": name,
                    "createdAt": Timestamp(date: Date())
                ],
                merge: true
            ) { error in
                if let error = error {
                    print("Failed to save deaf user profile: \(error.localizedDescription)")
                } else {
                    print("✅ Deaf user profile saved with Firebase UID: \(uid)")
                }
            }
    }
    
    // MARK: - Create translator profile
    func createTranslatorProfile(
        name: String,
        gender: String,
        age: Int,
        level: String,
        price: String,
        careers: [String]
    ) {
        guard let uid = user?.uid else { return }

        db.collection("users")
            .document(uid)  // ✅ Use Firebase UID as document ID
            .setData([
                "firebaseUID": uid,  // ✅ Also store as field
                "name": name,
                "gender": gender,
                "age": age,
                "level": level,
                "price": price,
                "careers": careers,
                "role": "interpreter",
                "createdAt": Timestamp(date: Date())
            ], merge: true) { error in
                if let error = error {
                    print("Failed to save translator profile: \(error.localizedDescription)")
                } else {
                    print("✅ Translator profile saved with Firebase UID: \(uid)")
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
                self.clearRole()
                completion(.success(()))
            }
    }
    
    // MARK: - Helpers
    
    func hasUserMadeChoice() -> Bool {
        return userRole != nil
    }
    
    func clearRole() {
        UserDefaults.standard.removeObject(forKey: roleStorageKey)
        DispatchQueue.main.async {
            self.userRole = nil
        }
    }
}
