import SwiftUI
import Combine

final class TermsViewModel: ObservableObject {
    
    @Published var isChecked: Bool = false
    @Published var isPresented: Bool = false
    
    @AppStorage("termsAccepted") private var termsAccepted: Bool = false
    
    func checkIfNeeded() {
        if !termsAccepted {
            isPresented = true
        }
    }
    
    func acceptTerms() {
        guard isChecked else { return }
        termsAccepted = true
        isPresented = false
    }
}
