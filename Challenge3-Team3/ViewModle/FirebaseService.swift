import Foundation
import FirebaseFirestore

class FirebaseService {
    static let shared = FirebaseService()
    private let db = Firestore.firestore()
    
    private init() {
        print("FirebaseService initialized")
    }
    
    // MARK: - Fetch all translators
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
                        print("⏭️ Skipping document \(doc.documentID) - missing essential fields")
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
                
                print("✅ Successfully created \(translators.count) translator objects")
                completion(.success(translators))
            }
    }
    
    // MARK: - Fetch translators by level
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
                
                print("Found \(documents.count) translators with level: \(level)")
                
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
    
    // MARK: - ✨ NEW: Create Appointment Request
    func createAppointment(deafUserId: String, deafName: String, translator: TranslatorData, completion: @escaping (Result<String, Error>) -> Void) {
        print("📝 Creating appointment request...")
        print("   Deaf User: \(deafName) (\(deafUserId))")
        print("   Translator: \(translator.name)")
        
        let appointmentData: [String: Any] = [
            "deafUserId": deafUserId,
            "deafName": deafName,
            "translatorId": translator.id,
            "translatorName": translator.name,
            "translatorGender": translator.gender,
            "translatorAge": translator.age,
            "translatorLevel": translator.level,
            "translatorPrice": translator.price,
            "translatorCategory": translator.category,
            "createdAt": FieldValue.serverTimestamp()
        ]
        
        db.collection("appointments").addDocument(data: appointmentData) { error in
            if let error = error {
                print("❌ Error creating appointment: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            print("✅ Appointment created successfully")
            completion(.success("Appointment created"))
        }
    }
    
    // MARK: - ✨ NEW: Fetch User's Appointments
    func fetchUserAppointments(userId: String, completion: @escaping (Result<[AppointmentRequest], Error>) -> Void) {
        print("🔍 Fetching appointments for user: \(userId)")
        
        db.collection("appointments")
            .whereField("deafUserId", isEqualTo: userId)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("❌ Error fetching appointments: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("⚠️ No appointments found")
                    completion(.success([]))
                    return
                }
                
                print("📦 Found \(documents.count) appointments")
                
                let appointments = documents.compactMap { doc -> AppointmentRequest? in
                    do {
                        var appointment = try doc.data(as: AppointmentRequest.self)
                        appointment.id = doc.documentID
                        return appointment
                    } catch {
                        print("❌ Error decoding appointment: \(error)")
                        return nil
                    }
                }
                
                print("✅ Successfully decoded \(appointments.count) appointments")
                completion(.success(appointments))
            }
    }
    
    // MARK: - ✨ NEW: Delete Appointment
    func deleteAppointment(appointmentId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        print("🗑️ Deleting appointment: \(appointmentId)")
        
        db.collection("appointments").document(appointmentId).delete { error in
            if let error = error {
                print("❌ Error deleting appointment: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            print("✅ Appointment deleted successfully")
            completion(.success(()))
        }
    }
}
