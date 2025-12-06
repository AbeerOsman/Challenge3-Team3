import SwiftUI

struct DeafNameSheet: View {
    let authViewModel: AuthViewModel
    @Binding var navigateToDeafHome: Bool
    @Binding var isPresented: Bool
    @Binding var deafName: String
    var onSave: (() -> Void)? = nil

    @State private var validationMessage: String?

    var body: some View {
        VStack(spacing: 20) {
            Capsule()
                .fill(Color.secondary.opacity(0.3))
                .frame(width: 40, height: 5)
                .padding(.top, 8)

            Text("Enter your name")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.primary)
                .padding(.top, 8)

            Text("We'll use this to personalize your experience and let translators know who is requesting help.")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            VStack(alignment: .leading, spacing: 8) {
                TextField("Your name", text: $deafName)
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled()
                    .padding(.horizontal, 14)
                    .frame(height: 48)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                    )
            }
            .padding(.horizontal)

            if let validationMessage = validationMessage {
                Text(validationMessage)
                    .font(.system(size: 13))
                    .foregroundColor(.red)
                    .padding(.top, -4)
            }

            Button(action: continueTapped) {
                Text("Continue")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "0D189F"), Color(hex: "0A1280")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(14)
                    .shadow(color: Color(hex: "0D189F").opacity(0.25), radius: 8, x: 0, y: 4)
            }
            .padding(.horizontal)

            Button(role: .cancel) {
                isPresented = false
            } label: {
                Text("Cancel")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(.secondary)
            }
            .padding(.top, 4)

            Spacer(minLength: 12)
        }
        .padding(.bottom, 16)
    }

    private func continueTapped() {
        let trimmed = deafName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            validationMessage = "Please enter your name."
            return
        }

        // Update binding with trimmed value
        deafName = trimmed

        // Persist profile
        authViewModel.createDeafUserProfile(name: trimmed)

        // Call the onSave callback (which updates AppStateManager)
        onSave?()

        // Dismiss sheet
        isPresented = false
    }
}

#Preview {
    StatefulPreview()
}

private struct StatefulPreview: View {
    @State private var show = true
    @State private var nav = false
    @State private var name = ""

    var body: some View {
        DeafNameSheet(
            authViewModel: AuthViewModel(),
            navigateToDeafHome: $nav,
            isPresented: $show,
            deafName: $name,
            onSave: {
                print("Name saved and AppStateManager updated")
            }
        )
    }
}
