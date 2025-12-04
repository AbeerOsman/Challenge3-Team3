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
        ZStack {
            backgroundColor.ignoresSafeArea()

            ScrollView {
                TranslatorHeaderView()
                VStack(spacing: 16) {

                    inputCard {
                        VStack(alignment: .leading, spacing: 12) {

                            // Name
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Name")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                TextField("Enter name", text: $viewModel.name)
                                    .textInputAutocapitalization(.words)
                                    .autocorrectionDisabled(true)
                                    .multilineTextAlignment(.leading)
                                    .padding(12)
                                    .background(Color.white)
                                    .cornerRadius(10)
                            }

                            // Gender
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Gender")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                Picker("Gender", selection: $viewModel.selectedGender) {
                                    ForEach(Gender.allCases) { gender in
                                        Text(gender.rawValue).tag(gender)
                                    }
                                }
                                .pickerStyle(.segmented)
                            }

                            // Age
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Age")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                TextField("Enter age", text: $viewModel.ageText)
                                    .keyboardType(.numberPad)
                                    .multilineTextAlignment(.leading)
                                    .padding(12)
                                    .background(Color.white)
                                    .cornerRadius(10)

                                Text("Minimum age is 18 years")
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }

                            // Level
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Level")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                Picker("Level", selection: $viewModel.selectedLevel) {
                                    ForEach(Level.allCases) { level in
                                        Text(level.rawValue).tag(level)
                                    }
                                }
                                .pickerStyle(.segmented)
                            }

                            // Plan
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Plan")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                Picker("Plan", selection: $viewModel.selectedPlan) {
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
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Hourly Rate")
                                        .font(.headline)
                                        .frame(maxWidth: .infinity, alignment: .leading)

                                    TextField("Enter rate (numbers only)", text: $viewModel.hourlyRateText)
                                        .keyboardType(.decimalPad)
                                        .multilineTextAlignment(.leading)
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
                                Text("Save Profile")
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
                                Text("Delete Profile")
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
        // IMPORTANT: apply navigation modifiers here (this view should be used inside an outer NavigationView)
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            Task { await viewModel.loadUserProfile() }
        }
    }

    // MARK: - Show message based on action
    private func showCustomAlertWithMessage() {
        alertMessage = viewModel.lastActionIsDelete
            ? "Data has been removed from the translator search interface successfully."
            : "Profile saved successfully and sent to sign language translator searchers."

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

                Button("OK") {
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

struct TranslatorHeaderView: View {
    @State private var showLogoutAlert = false
    @State private var goToSplash = false

    var body: some View {
        HStack {
            Spacer()

            Button {
                showLogoutAlert = true
            } label: {
                VStack(spacing: 4) {
                    Image(systemName: "iphone.and.arrow.right.outward")
                        .font(.system(size: 24))
                        .foregroundColor(.red)

                    Text("SignOut")
                        .font(.system(size: 13))
                        .foregroundColor(.red)
                }
                .padding(.trailing, 20)
            }
            .alert("Are you sure you want to sign out?", isPresented: $showLogoutAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Sign Out", role: .destructive) {
                    goToSplash = true
                }
            }

            // Hidden NavigationLink
            NavigationLink(destination: ChoiceView(), isActive: $goToSplash) {
                EmptyView()
            }
        }
        .padding(.vertical, 16)
    }
}
