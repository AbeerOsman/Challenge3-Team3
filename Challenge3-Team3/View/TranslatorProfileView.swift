import SwiftUI

// MARK: - ProfileView
struct TranslatorProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()

    @State private var showCustomAlert = false
    @State private var alertMessage = ""

    private let backgroundColor = Color(red: 240/255, green: 245/255, blue: 255/255)
    private let cardColor = Color(red: 221/255, green: 232/255, blue: 253/255)
    private let buttonColor = Color(red: 13/255, green: 24/255, blue: 159/255)

    var body: some View {
        NavigationView {
            ZStack {
                backgroundColor.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        inputCard {
                            VStack(alignment: .trailing, spacing: 12) {

                                // الاسم
                                VStack(alignment: .trailing, spacing: 6) {
                                    Text("الاسم")
                                        .font(.headline)
                                        .frame(maxWidth: .infinity, alignment: .trailing)

                                    TextField("أدخل الاسم", text: $viewModel.name)
                                        .textInputAutocapitalization(.words)
                                        .autocorrectionDisabled(true)
                                        .multilineTextAlignment(.trailing)
                                        .padding(12)
                                        .background(Color.white)
                                        .cornerRadius(10)
                                }

                                // الجنس
                                VStack(alignment: .trailing, spacing: 6) {
                                    Text("الجنس")
                                        .font(.headline)
                                        .frame(maxWidth: .infinity, alignment: .trailing)

                                    Picker("الجنس", selection: $viewModel.selectedGender) {
                                        ForEach(Gender.allCases) { gender in
                                            Text(gender.rawValue).tag(gender)
                                        }
                                    }
                                    .pickerStyle(.segmented)
                                }

                                // العمر
                                VStack(alignment: .trailing, spacing: 6) {
                                    Text("العمر")
                                        .font(.headline)
                                        .frame(maxWidth: .infinity, alignment: .trailing)

                                    TextField("أدخل العمر", text: $viewModel.ageText)
                                        .keyboardType(.numberPad)
                                        .multilineTextAlignment(.trailing)
                                        .padding(12)
                                        .background(Color.white)
                                        .cornerRadius(10)

                                    Text("الحد الأدنى للعمر هو 18 سنة")
                                        .font(.footnote)
                                        .foregroundColor(.secondary)
                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                }

                                // المستوى
                                VStack(alignment: .trailing, spacing: 6) {
                                    Text("المستوى")
                                        .font(.headline)
                                        .frame(maxWidth: .infinity, alignment: .trailing)

                                    Picker("المستوى", selection: $viewModel.selectedLevel) {
                                        ForEach(Level.allCases) { level in
                                            Text(level.rawValue).tag(level)
                                        }
                                    }
                                    .pickerStyle(.segmented)
                                }

                                // الفئة
                                VStack(alignment: .trailing, spacing: 6) {
                                    Text("الفئة")
                                        .font(.headline)
                                        .frame(maxWidth: .infinity, alignment: .trailing)

                                    Picker("الفئة", selection: $viewModel.selectedPlan) {
                                        ForEach(Plan.allCases) { plan in
                                            Text(plan.rawValue).tag(plan)
                                        }
                                    }
                                    .pickerStyle(.segmented)
                                    .onChange(of: viewModel.selectedPlan) { _, newValue in
                                        if newValue == .free {
                                            viewModel.hourlyRateText = ""
                                        }
                                    }
                                }

                                // السعر
                                if viewModel.selectedPlan == .paid {
                                    VStack(alignment: .trailing, spacing: 6) {
                                        Text("السعر بالساعة")
                                            .font(.headline)
                                            .frame(maxWidth: .infinity, alignment: .trailing)

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
                                }
                            }
                        }
                        .padding(.horizontal)

                        // أزرار الحفظ والحذف
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
                                    Text("حفظ البيانات")
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
                                    Text("حذف البيانات")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .border(.gray, width: 1)
                                .foregroundColor(.red)
                                .cornerRadius(14)
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
            .onAppear {
                Task { await viewModel.loadUserProfile() }
            }
        }
    }

    // MARK: - Show message based on action
    private func showCustomAlertWithMessage() {
        alertMessage = viewModel.lastActionIsDelete
        ? "تم حذف البيانات من واجهة الباحثين عن مترجم بنجاح"
        : "تم حفظ البيانات بنجاح، وإرسالها للباحثين عن مترجم لغة إشارة"

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
        TranslatorProfileView()
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

                Button("حسناً") {
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
