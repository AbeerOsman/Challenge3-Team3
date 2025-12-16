import SwiftUI

struct TranslatorProfileView: View {
    @Binding var isPresented: Bool
    var parentViewModel: ProfileViewModel?
    
    @StateObject private var viewModel = ProfileViewModel()
    @Environment(\.dismiss) var dismiss
    
    @State private var showCustomAlert = false
    @State private var alertMessage = ""
    @State private var showCareerDropdown = false
    @State private var isTermsAccepted = false
    @State private var showTerms = false

    private let backgroundColor = Color(red: 240/255, green: 245/255, blue: 255/255)
    private let cardColor = Color(red: 221/255, green: 232/255, blue: 253/255)
    private let buttonColor = Color(red: 13/255, green: 24/255, blue: 159/255)

    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    Spacer()
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
                                    .multilineTextAlignment(.trailing)
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
                                    .multilineTextAlignment(.trailing)
                                    .padding(12)
                                    .background(Color.white)
                                    .cornerRadius(10)

                                Text("الحد الأدنى للعمر 18 سنة")
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
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

                            // Career (Multi-select Dropdown)
                            VStack(alignment: .trailing, spacing: 6) {
                                Text("المسار المهني")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .multilineTextAlignment(.leading)

                                Button(action: { showCareerDropdown.toggle() }) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "chevron.down")
                                            .font(.system(size: 12, weight: .semibold))
                                            .rotationEffect(.degrees(showCareerDropdown ? 180 : 0))
                                            .foregroundColor(buttonColor)

                                        Text(getCareerButtonText())
                                            .font(.system(size: 14))
                                            .foregroundColor(viewModel.selectedCareers.isEmpty ? .gray : .black)

                                        Spacer()
                                    }
                                    .padding(12)
                                    .background(Color.white)
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(buttonColor.opacity(0.3), lineWidth: 1)
                                    )
                                }

                                if showCareerDropdown {
                                    VStack(alignment: .trailing, spacing: 8) {
                                        ForEach(Career.allCases.filter { $0 != .none }, id: \.self) { career in
                                            Button(action: { toggleCareer(career) }) {
                                                HStack(spacing: 12) {
                                                    Image(systemName: viewModel.selectedCareers.contains(career) ? "checkmark.square.fill" : "square")
                                                        .font(.system(size: 16))
                                                        .foregroundColor(viewModel.selectedCareers.contains(career) ? buttonColor : .gray)

                                                    Text(career.rawValue)
                                                        .font(.system(size: 14))
                                                        .foregroundColor(.black)

                                                    Spacer()
                                                }
                                                .padding(.vertical, 10)
                                                .padding(.horizontal, 12)
                                                .background(viewModel.selectedCareers.contains(career) ? buttonColor.opacity(0.1) : Color.clear)
                                                .cornerRadius(8)
                                            }
                                        }
                                    }
                                    .padding(12)
                                    .background(Color.white)
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(buttonColor.opacity(0.2), lineWidth: 1)
                                    )
                                    .transition(.opacity)
                                }
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
                    
                    // MARK: - Terms & Conditions
                    HStack(spacing: 10) {

                        Button {
                            isTermsAccepted.toggle()
                        } label: {
                            Image(systemName: isTermsAccepted ? "checkmark.square.fill" : "square")
                                .font(.system(size: 20))
                                .foregroundColor(
                                    isTermsAccepted
                                    ? buttonColor
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
                                .foregroundColor(buttonColor)
                                .underline()
                        }
                        .buttonStyle(.plain)

                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 4)


                    // Save Button
                    VStack(spacing: 8) {
                        Button {
                            Task {
                                await viewModel.saveUserProfile()
                                showCustomAlertWithMessage()

                                if let parent = parentViewModel {
                                    await parent.loadUserProfile()
                                }
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
                            .background(
                                isTermsAccepted && !viewModel.isSaving
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
                            .foregroundColor(.white)
                            .cornerRadius(14)
                        }
                        .disabled(viewModel.isSaving || !isTermsAccepted)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 24)
                    
                }
                .padding(.top, 16)
            }

            if showCustomAlert {
                CenteredAlertView(message: alertMessage) {
                    showCustomAlert = false
                    if alertMessage.contains("بنجاح") && !alertMessage.contains("حذف") {
                        isPresented = false
                    }
                }
            }
        }
        .sheet(isPresented: $showTerms) {
            TermsPopupView(viewModel: TermsViewModel())
        }
        
        .navigationTitle("تعديل الملف الشخصي")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    isPresented = false
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(buttonColor)
                }
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
        .onAppear {
            Task { await viewModel.loadUserProfile() }
        }
    }

    private func getCareerButtonText() -> String {
        if viewModel.selectedCareers.isEmpty {
            return "اختر المسار المهني"
        }
        return viewModel.selectedCareers.map { $0.rawValue }.joined(separator: "، ")
    }

    private func toggleCareer(_ career: Career) {
        if viewModel.selectedCareers.contains(career) {
            viewModel.selectedCareers.remove(career)
        } else {
            viewModel.selectedCareers.insert(career)
        }
    }

    private func showCustomAlertWithMessage() {
        alertMessage = "تم حفظ الملف الشخصي بنجاح وإرساله إلى الباحثين عن مترجمي الإشارة."
        showCustomAlert = true
    }

    @ViewBuilder
    private func inputCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack { content() }
            .padding(16)
            .background(cardColor)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
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
                .background(Color(red: 13/255, green: 24/255, blue: 159/255))
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

#Preview {
    NavigationStack {
        TranslatorProfileView(isPresented: .constant(true))
            .environment(\.layoutDirection, .rightToLeft)
    }
}
