////
////  TranslatorsListViewModel.swift
////  tran
////
////  Created by Shahad Alsubaie on 08/06/1447 AH.
////
//import Foundation
//import FirebaseFirestore
////import FirebaseFirestoreSwift
//import Combine
//
//@MainActor
//class TranslatorsListViewModel: ObservableObject {
//    @Published var translators: [UserProfile] = []
//    @Published var rawDocuments: [[String: Any]] = []
//
//    private var db = Firestore.firestore()
//    private var listener: ListenerRegistration?
//
//    deinit {
//        listener?.remove()
//    }
//
//    func startListening() {
//        let settings = FirestoreSettings()
//        settings.isPersistenceEnabled = false
//        db.settings = settings
//
//        listener?.remove()
//
//        listener = db.collection("users")
//            .addSnapshotListener { [weak self] snapshot, error in
//                guard let self = self else { return }
//
//                if let error = error {
//                    print("❌ خطأ في الاستماع للمترجمين: \(error)")
//                    self.translators = []
//                    self.rawDocuments = []
//                    return
//                }
//
//                guard let documents = snapshot?.documents else {
//                    print("ℹ️ لا توجد مستندات في users")
//                    self.translators = []
//                    self.rawDocuments = []
//                    return
//                }
//
//                print("📦 عدد المستندات المستلمة من Firestore: \(documents.count)")
//
//                var decoded: [UserProfile] = []
//                decoded.reserveCapacity(documents.count)
//
//                var raws: [[String: Any]] = []
//                raws.reserveCapacity(documents.count)
//
//                var decodeFailures = 0
//
//                for document in documents {
//                    var raw = document.data()
//                    raw["documentID"] = document.documentID
//                    raws.append(raw)
//
//                    do {
//                        let profile = try document.data(as: UserProfile.self)
//                        decoded.append(profile)
//                    } catch {
//                        decodeFailures += 1
//                        print("⚠️ فشل فك ترميز المترجم \(document.documentID): \(error)")
//                        print("📄 البيانات الخام: \(document.data())")
//                    }
//                }
//
//                print("✅ نجح فك ترميز: \(decoded.count) | ❌ فشل: \(decodeFailures)")
//
//                self.translators = decoded
//                self.rawDocuments = raws
//            }
//    }
//
//    func stopListening() {
//        listener?.remove()
//        listener = nil
//    }
//}
