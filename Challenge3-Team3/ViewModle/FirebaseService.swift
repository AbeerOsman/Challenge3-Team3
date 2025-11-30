import Foundation
import FirebaseFirestore

class FirebaseService {
    static let shared = FirebaseService()
    private let db = Firestore.firestore()
    
    private init() {
        print("FirebaseService initialized")
    }
    
    
    // Fetch all translators from Firestore
    func fetchTranslators(completion: @escaping (Result<[TranslatorData], Error>) -> Void) {
        print("🔍 Starting to fetch translators...")
        
        db.collection("users")
            .getDocuments { snapshot, error in
                if let error = error {
                    print("❌ Error fetching translators: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("⚠️ No documents found in snapshot")
                    completion(.success([]))
                    return
                }
                
                print("Found \(documents.count) documents in 'users' collection")
                
                let translators = documents.compactMap { doc -> TranslatorData? in
                    let data = doc.data()
                    
                    // Handle both data structures:
                    // Structure 1: category + price
                    // Structure 2: plan + hourlyRate
                    
                    let name = data["name"] as? String ?? ""
                    let gender = data["gender"] as? String ?? ""
                    let age = data["age"] as? Int ?? 0
                    let level = data["level"] as? String ?? ""
                    
                    // Check for both price fields
                    var price = 0
                    var category = ""
                    
                    if let priceValue = data["price"] as? Int {
                        // Structure 1: using category + price
                        price = priceValue
                        category = data["category"] as? String ?? ""
                    } else if let hourlyRate = data["hourlyRate"] as? Int {
                        // Structure 2: using plan + hourlyRate
                        price = hourlyRate
                        category = data["plan"] as? String ?? ""
                    }
                    
                    // Skip if essential fields are missing
                    guard !name.isEmpty && !level.isEmpty else {
                        print("⏭️ Skipping document \(doc.documentID) - missing essential fields")
                        return nil
                    }
                    
                    print("✅ Creating TranslatorData for: \(name)")
                    
                    return TranslatorData(
                        id: doc.documentID,
                        name: name,
                        gender: gender,
                        age: "\(age)",
                        level: level,
                        price: "\(price)",
                        category: category
                    )
                }
                
                print("✅ Successfully created \(translators.count) translator objects")
                completion(.success(translators))
            }
    }
    
    // Fetch translators filtered by level
    func fetchTranslatorsByLevel(level: String, completion: @escaping (Result<[TranslatorData], Error>) -> Void) {
        print("🔍 Fetching translators with level: \(level)")
        
        db.collection("users")
            .whereField("level", isEqualTo: level)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("❌ Error filtering translators: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("⚠️ No documents found for level: \(level)")
                    completion(.success([]))
                    return
                }
                
                print(" Found \(documents.count) translators with level: \(level)")
                
                let translators = documents.compactMap { doc -> TranslatorData? in
                    let data = doc.data()
                    
                    let name = data["name"] as? String ?? ""
                    let gender = data["gender"] as? String ?? ""
                    let age = data["age"] as? Int ?? 0
                    let level = data["level"] as? String ?? ""
                    
                    var price = 0
                    var category = ""
                    
                    if let priceValue = data["price"] as? Int {
                        price = priceValue
                        category = data["category"] as? String ?? ""
                    } else if let hourlyRate = data["hourlyRate"] as? Int {
                        price = hourlyRate
                        category = data["plan"] as? String ?? ""
                    }
                    
                    guard !name.isEmpty && !level.isEmpty else {
                        return nil
                    }
                    
                    return TranslatorData(
                        id: doc.documentID,
                        name: name,
                        gender: gender,
                        age: "\(age)",
                        level: level,
                        price: "\(price)",
                        category: category
                    )
                }
                
                completion(.success(translators))
            }
    }
}
