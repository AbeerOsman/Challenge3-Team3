import SwiftUI

// MARK: - ProfileView
struct TranslatorProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @Environment(\.dismiss) var dismiss
    
    @State private var showCustomAlert = false
    @State private var alertMessage = ""

    private let backgroundColor = Color(red: 240/255, green: 245/255, blue: 255/255)
    private let cardColor = Color(red: 221/255, green: 232/255, blue: 253/255)
    private let buttonColor = Color(red: 13/255, green: 24/255, blue: 159/255)

    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()

            ScrollView {
                
                VStack(spacing: 16) {

                    inputCard {
                        VStack(alignment: .trailing, spacing: 12) {

                            // Name
                            VStack(alignment: .trailing, spacing: 6) {
                                Text("الاسم")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .multilineTextAlignment(.leading)

                                TextField("أدخل الاسم", text: $viewModel.name)
                                    .textInputAutocapitalization(.words)
                                    .autocorrectionDisabled(true)
                                    .multilineTextAlignment(.leading)
                                    .padding(12)
                                    .background(Color.white)
                                    .cornerRadius(10)
                            }

                            // Gender
                            VStack(alignment: .trailing, spacing: 6) {
                                Text("الجنس")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .multilineTextAlignment(.leading)

                                Picker("الجنس", selection: $viewModel.selectedGender) {
                                    ForEach(Gender.allCases) { gender in
                                        Text(gender.rawValue).tag(gender)
                                    }
                                }
                                .pickerStyle(.segmented)
                            }

                            // Age
                            VStack(alignment: .trailing, spacing: 6) {
                                Text("العمر")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .multilineTextAlignment(.leading)

                                TextField("أدخل العمر", text: $viewModel.ageText)
                                    .keyboardType(.numberPad)
                                    .multilineTextAlignment(.leading)
                                    .padding(12)
                                    .background(Color.white)
                                    .cornerRadius(10)

                                Text("الحد الأدنى للعمر 18 سنة")
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .
                                    leading)
                                    .multilineTextAlignment(.leading)
                            }

                            // Level
                            VStack(alignment: .trailing, spacing: 6) {
                                Text("المستوى")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .multilineTextAlignment(.leading)

                                Picker("المستوى", selection: $viewModel.selectedLevel) {
                                    ForEach(Level.allCases) { level in
                                        Text(level.rawValue).tag(level)
                                    }
                                }
                                .pickerStyle(.segmented)
                            }

                            // Plan
                            VStack(alignment: .trailing, spacing: 6) {
                                Text("الخطة")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .multilineTextAlignment(.leading)

                                Picker("الخطة", selection: $viewModel.selectedPlan) {
                                    ForEach(Plan.allCases) { plan in
                                        Text(plan.rawValue).tag(plan)
                                    }
                                }
                                .pickerStyle(.segmented)
                                .onChange(of: viewModel.selectedPlan) { newValue in
                                    if newValue == .free {
                                        viewModel.hourlyRateText = ""
                                    }
                                }
                            }

                            // Hourly rate
                            if viewModel.selectedPlan == .paid {
                                VStack(alignment: .trailing, spacing: 6) {
                                    Text("السعر بالساعة")
                                        .font(.headline)
                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                        .multilineTextAlignment(.trailing)

                                    TextField("أدخل السعر (أرقام فقط)", text: $viewModel.hourlyRateText)
                                        .keyboardType(.decimalPad)
                                        .multilineTextAlignment(.trailing)
                                        .padding(12)
                                        .background(Color.white)
                                        .cornerRadius(10)
                                }
                            }

                            if let error = viewModel.errorMessage {
                                Text(error)
                                    .foregroundColor(.red)
                                    .font(.subheadline)
                                    .multilineTextAlignment(.center)
                                    .frame(maxWidth: .infinity, alignment: .center)
                            }
                        }
                    }
                    .padding(.horizontal)

                    // Save & Delete Buttons
                    VStack(spacing: 8) {
                        Button {
                            Task {
                                await viewModel.saveUserProfile()
                                showCustomAlertWithMessage()
                            }
                        } label: {
                            HStack {
                                if viewModel.isSaving {
                                    ProgressView().tint(.white)
                                }
                                Text("حفظ الملف الشخصي")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(buttonColor)
                            .foregroundColor(.white)
                            .cornerRadius(14)
                        }
                        .disabled(viewModel.isSaving)


                        Button(role: .destructive) {
                            Task {
                                await viewModel.deleteUserProfile()
                                showCustomAlertWithMessage()
                            }
                        } label: {
                            HStack {
                                Image(systemName: "trash")
                                Text("حذف الملف الشخصي")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                            .foregroundColor(.red)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 24)
                }
                .padding(.top, 16)
            }

            if showCustomAlert {
                CenteredAlertView(message: alertMessage) {
                    showCustomAlert = false
                }
            }
        }
        .navigationTitle("الملف الشخصي")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            dismiss()
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundColor(buttonColor)
                        }
                    }
                }
        .environment(\.layoutDirection, .rightToLeft) // RTL
        .onAppear {
            Task { await viewModel.loadUserProfile() }
        }
    }

    // MARK: - Show message based on action
    private func showCustomAlertWithMessage() {
        alertMessage = viewModel.lastActionIsDelete
            ? "تمت إزالة البيانات من واجهة البحث عن مترجمين لغة الإشارة بنجاح."
            : "تم حفظ الملف الشخصي بنجاح وإرساله إلى الباحثين عن مترجمي الإشارة."

        showCustomAlert = true
    }

    // MARK: - Input Card
    @ViewBuilder
    private func inputCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack { content() }
            .padding(16)
            .background(cardColor)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        // Wrap preview in a NavigationView to simulate being pushed from parent
        NavigationView {
            TranslatorProfileView()
                .environment(\.layoutDirection, .rightToLeft)
        }
    }
}

struct CenteredAlertView: View {
    var message: String
    var onDismiss: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.35)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Text(message)
                    .font(.system(size: 18))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.black)
                    .padding(.horizontal, 16)

                Button("موافق") {
                    onDismiss()
                }
                .font(.system(size: 16, weight: .bold))
                .padding(.vertical, 8)
                .padding(.horizontal, 40)
                .background(Color(hex: "0D189F"))
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .padding()
            .frame(maxWidth: 370)
            .background(Color.white)
            .cornerRadius(18)
            .shadow(radius: 20)
        }
        .transition(.scale)
        .animation(.spring(), value: message)
    }
}
