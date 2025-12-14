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
                    
                    // Handle price field (can be "price" or "hourlyRate")
                    if let priceValue = data["price"] as? Int {
                        price = priceValue
                        category = data["category"] as? String ?? ""
                    } else if let hourlyRate = data["hourlyRate"] as? Int {
                        price = hourlyRate
                        category = data["plan"] as? String ?? ""
                    } else if let hourlyRate = data["hourlyRate"] as? Double {
                        price = Int(hourlyRate)
                        category = data["plan"] as? String ?? ""
                    }
                    
                    // Handle multiple careers
                    var careersArray: [String] = []
                    var careerDisplayString = ""
                    
                    if let careersFromFirebase = data["careers"] as? [String] {
                        careersArray = careersFromFirebase.filter { !$0.isEmpty && $0 != "بدون" }
                        careerDisplayString = careersArray.joined(separator: "، ")
                    } else if let singleCareer = data["career"] as? String {
                        if !singleCareer.isEmpty && singleCareer != "بدون" {
                            careersArray = [singleCareer]
                            careerDisplayString = singleCareer
                        }
                    }
                    
                    guard !name.isEmpty && !level.isEmpty else {
                        return nil
                    }
                    
                    // ✅ Get Firebase UID - use the document ID which IS the Firebase UID
                    let firebaseUID = doc.documentID
                    
                    return TranslatorData(
                        id: doc.documentID,
                        firebaseUID: firebaseUID,  // ✅ NEW
                        name: name,
                        gender: gender,
                        age: "\(age)",
                        level: level,
                        price: "\(price)",
                        category: category,
                        career: careerDisplayString,
                        careers: careersArray
                    )
                }
                
                print("Successfully created \(translators.count) translator objects")
                completion(.success(translators))
            }
    }

    // Same update for fetchTranslatorsByLevel
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
                    } else if let hourlyRate = data["hourlyRate"] as? Double {
                        price = Int(hourlyRate)
                        category = data["plan"] as? String ?? ""
                    }
                    
                    var careersArray: [String] = []
                    var careerDisplayString = ""
                    
                    if let careersFromFirebase = data["careers"] as? [String] {
                        careersArray = careersFromFirebase.filter { !$0.isEmpty && $0 != "بدون" }
                        careerDisplayString = careersArray.joined(separator: "، ")
                    } else if let singleCareer = data["career"] as? String {
                        if !singleCareer.isEmpty && singleCareer != "بدون" {
                            careersArray = [singleCareer]
                            careerDisplayString = singleCareer
                        }
                    }
                    
                    guard !name.isEmpty && !level.isEmpty else {
                        return nil
                    }
                    
                    // ✅ Get Firebase UID
                    let firebaseUID = doc.documentID
                    
                    return TranslatorData(
                        id: doc.documentID,
                        firebaseUID: firebaseUID,  // ✅ NEW
                        name: name,
                        gender: gender,
                        age: "\(age)",
                        level: level,
                        price: "\(price)",
                        category: category,
                        career: careerDisplayString,
                        careers: careersArray
                    )
                }
                
                completion(.success(translators))
            }
    }
    
    // MARK: - Appointments
    // Replace your createAppointment function with this:

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
            "createdAt": FieldValue.serverTimestamp()  // ✅ Ensure this is saved
        ]
        
        db.collection("appointments").addDocument(data: appointmentData) { error in
            if let error = error {
                print("❌ Error creating appointment: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            print("✅ Appointment created successfully with createdAt timestamp")
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
                
                if documents.isEmpty {
                    print("✅ No appointments to delete")
                    completion(.success(()))
                    return
                }
                
                let batch = self.db.batch()
                
                for document in documents {
                    batch.deleteDocument(document.reference)
                    print("   ➕ Marked appointment for deletion: \(document.documentID)")
                }
                
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
    
    // MARK: - Deaf users
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
    
    // Add this function to FirebaseService class to debug messages

    func debugCheckMessages(chatRoomId: String) {
        print("🔍 DEBUG: Checking messages in chatRoom: \(chatRoomId)")
        
        db.collection("chatRooms")
            .document(chatRoomId)
            .collection("messages")
            .getDocuments { snapshot, error in
                if let error = error {
                    print("❌ Error checking messages: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("⚠️ No messages found in chatRoom: \(chatRoomId)")
                    return
                }
                
                print("📦 Found \(documents.count) messages in chatRoom: \(chatRoomId)")
                for (index, doc) in documents.enumerated() {
                    let data = doc.data()
                    print("   Message \(index + 1):")
                    print("     ID: \(data["id"] as? String ?? "N/A")")
                    print("     Text: \(data["text"] as? String ?? "N/A")")
                    print("     From: \(data["senderName"] as? String ?? "N/A")")
                    print("     Sender ID: \(data["senderId"] as? String ?? "N/A")")
                }
            }
    }

}

