import Foundation
import FirebaseFirestore

class FirebaseService {
    static let shared = FirebaseService()
    private let db = Firestore.firestore()
    
    private var translatorsListener: ListenerRegistration?
    private var appointmentsListener: ListenerRegistration?
    
    private init() {
        print("🔥 FirebaseService initialized")
    }
    
    // MARK: - Translators (users collection)
    func fetchTranslators(completion: @escaping (Result<[TranslatorData], Error>) -> Void) {
        print("🔍 Setting up translators listener...")
        
        translatorsListener?.remove()
        
        translatorsListener = db.collection("users")
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error fetching translators: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("No documents found in snapshot")
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
                
                print("Successfully created \(translators.count) translator objects")
                completion(.success(translators))
            }
    }
    
    func fetchTranslatorsByLevel(level: String, completion: @escaping (Result<[TranslatorData], Error>) -> Void) {
        print("🔍 Setting up level filter listener for: \(level)")
        
        translatorsListener?.remove()
        
        translatorsListener = db.collection("users")
            .whereField("level", isEqualTo: level)
            .addSnapshotListener { snapshot, error in
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
                
                print("📦 Found \(documents.count) translators with level: \(level)")
                
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
    
    // MARK: - Appointments
    func createAppointment(
        deafUserId: String,
        deafName: String,
        translatorId: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        print("📝 Creating appointment request...")
        print("   Deaf User: \(deafName) (\(deafUserId))")
        print("   Translator ID: \(translatorId)")
        
        let appointmentData: [String: Any] = [
            "deafUserId": deafUserId,
            "deafName": deafName,
            "translatorId": translatorId,
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
    
    func fetchUserAppointments(
        userId: String,
        completion: @escaping (Result<[AppointmentRequest], Error>) -> Void
    ) {
        print("🔍 Setting up appointments listener for user: \(userId)")
        
        appointmentsListener?.remove()
        
        appointmentsListener = db.collection("appointments")
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
    
    func deleteAppointment(
        appointmentId: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
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
    
    // MARK: - Cascade Delete User Appointments
    func deleteAllUserAppointments(
        userId: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        print("🗑️ Deleting all appointments for user: \(userId)")
        
        // First, fetch all appointments for this user
        db.collection("appointments")
            .whereField("deafUserId", isEqualTo: userId)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("❌ Error fetching appointments for deletion: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("⚠️ No appointments found for user: \(userId)")
                    completion(.success(()))
                    return
                }
                
                print("📦 Found \(documents.count) appointments to delete for user: \(userId)")
                
                // If no appointments, return success
                if documents.isEmpty {
                    print("✅ No appointments to delete")
                    completion(.success(()))
                    return
                }
                
                // Delete all appointments in batch
                let batch = self.db.batch()
                
                for document in documents {
                    batch.deleteDocument(document.reference)
                    print("   ➕ Marked appointment for deletion: \(document.documentID)")
                }
                
                // Commit the batch
                batch.commit { error in
                    if let error = error {
                        print("❌ Error batch deleting appointments: \(error.localizedDescription)")
                        completion(.failure(error))
                        return
                    }
                    
                    print("✅ Successfully deleted \(documents.count) appointments for user: \(userId)")
                    completion(.success(()))
                }
            }
    }
    
    func removeAllListeners() {
        print("🧹 Removing all Firebase listeners")
        translatorsListener?.remove()
        appointmentsListener?.remove()
    }
    
    // MARK: - Deaf users (ONLY this collection will be touched)
    func deleteDeafUser(
        userId: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        print("🗑️ Deleting deaf user from 'deafUsers': \(userId)")
        
        db.collection("deafUsers").document(userId).delete { error in
            if let error = error {
                print("❌ Error deleting deaf user: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            print("✅ Deaf user deleted from 'deafUsers'")
            completion(.success(()))
        }
    }
}
