import SwiftUI

struct DeafNameSheet: View {

    let authViewModel: AuthViewModel
    @Binding var navigateToDeafHome: Bool
    @Binding var isPresented: Bool
    @Binding var deafName: String
    var onSave: (() -> Void)? = nil

    @State private var validationMessage: String?
    @State private var isTermsAccepted = false
    @State private var showTerms = false

    var body: some View {
        VStack(spacing: 20) {

            Capsule()
                .fill(Color.secondary.opacity(0.3))
                .frame(width: 40, height: 5)
                .padding(.top, 8)

            Text("أدخل إسمك الكامل")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.primary)

            Text("سنستخدم هذا لتخصيص تجربتك وإخبار المترجمين من يطلب المساعدة.")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            // MARK: - Name Field
            VStack(alignment: .leading, spacing: 6) {

                TextField("اسمك", text: $deafName)
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled()
                    .padding(.horizontal, 14)
                    .frame(height: 48)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                    )
                    .environment(\.layoutDirection, .rightToLeft)

                // MARK: - Terms Checkbox (⬅️ هنا المطلوب)
                HStack(spacing: 10) {

                    Button {
                        isTermsAccepted.toggle()
                    } label: {
                        Image(systemName: isTermsAccepted ? "checkmark.square.fill" : "square")
                            .font(.system(size: 20))
                            .foregroundColor(
                                isTermsAccepted
                                ? Color.darkblue
                                : .secondary
                            )
                    }
                    .buttonStyle(.plain)

                    Text("أوافق على")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)

                    Button {
                        showTerms = true
                    } label: {
                        Text("الشروط والأحكام")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color.darkblue)
                            .underline()
                    }
                    .buttonStyle(.plain)

                    Spacer()
                }
                .padding(.top, 4)
            }
            .padding(.horizontal)

            if let validationMessage = validationMessage {
                Text(validationMessage)
                    .font(.system(size: 13))
                    .foregroundColor(.red)
            }

            // MARK: - Continue Button
            Button(action: continueTapped) {
                Text("متابعة")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        isTermsAccepted
                        ? LinearGradient(
                            colors: [Color(hex: "0D189F"), Color(hex: "0A1280")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        : LinearGradient(
                            colors: [Color.gray.opacity(0.4), Color.gray.opacity(0.4)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .cornerRadius(14)
            }
            .disabled(!isTermsAccepted)
            .padding(.horizontal)

            Button("إلغاء") {
                isPresented = false
            }
            .font(.system(size: 15))
            .foregroundColor(.secondary)

            Spacer(minLength: 12)
        }
        .padding(.bottom, 16)
        .environment(\.layoutDirection, .rightToLeft)
        .sheet(isPresented: $showTerms) {
            TermsPopupView(
                viewModel: TermsViewModel()
            )
        }
    }

    // MARK: - Actions
    private func continueTapped() {

        let trimmed = deafName.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmed.isEmpty else {
            validationMessage = "يرجى إدخال اسمك."
            return
        }

        guard isTermsAccepted else {
            validationMessage = "يجب الموافقة على الشروط والأحكام."
            return
        }

        deafName = trimmed
        authViewModel.createDeafUserProfile(name: trimmed)
        onSave?()
        isPresented = false
    }
}


#Preview {
    DeafNameSheetPreviewWrapper()
}

private struct DeafNameSheetPreviewWrapper: View {
    @State private var show = true
    @State private var navigate = false
    @State private var name = ""

    var body: some View {
        DeafNameSheet(
            authViewModel: AuthViewModel(),
            navigateToDeafHome: $navigate,
            isPresented: $show,
            deafName: $name,
            onSave: {
                print("تم الحفظ من Preview")
            }
        )
    }
}
