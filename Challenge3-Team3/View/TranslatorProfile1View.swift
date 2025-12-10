import SwiftUI

struct MainTranslatorProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @State private var showEditSheet = false
    @State private var showDeleteAlert = false
    @State private var showCustomAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color(hex: "F7F9FF"), Color(hex: "F2F6FF")]),
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                Text("الملف الشخصي")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.top, 24)
                    .padding(.bottom, 24)
                
                // Card Container
                ScrollView {
                    VStack(spacing: 0) {
                        // Profile Header Section
                        VStack(alignment: .leading, spacing: 16) {
                            
                            HStack(spacing: 16) {
                                if viewModel.selectedGender == .female {
                                    Image("femaleIcon")
                                        .resizable()
                                        .renderingMode(.template)
                                        .scaledToFit()
                                        .frame(width: 65, height: 65)
                                        .foregroundColor(Color(hex: "DC7F7F"))
                                } else {
                                    Image("maleIcon")
                                        .resizable()
                                        .renderingMode(.template)
                                        .scaledToFit()
                                        .frame(width: 65, height: 65)
                                        .foregroundColor(Color(hex: "092B6F"))
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(viewModel.name.isEmpty ? "لم يتم تحديد الإسم بعد" : viewModel.name)
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundColor(.black)
                                    
                                    HStack(spacing: 4) {
                                        Circle()
                                            .fill(viewModel.selectedPlan == .free ? Color(hex: "4CAF50") : Color(hex: "F77575"))
                                            .frame(width: 10, height: 10)
                                        
                                        Text(viewModel.selectedPlan.rawValue)
                                            .font(.system(size: 15))
                                            .foregroundColor(viewModel.selectedPlan == .free ? Color(hex: "4CAF50") : Color(hex: "F77575"))
                                    }
                                }
                                
                                Spacer()
                            }
                        }
                        .padding(8)
                        
                        // Stats Section
                        HStack(spacing: 12) {
                            // Age Card
                            VStack(spacing: 6) {
                                Image(systemName: "calendar")
                                    .font(.system(size: 25))
                                    .foregroundColor(Color(hex: "0D189F"))
                                
                                Text("العمر")
                                    .font(.system(size: 11))
                                    .foregroundColor(Color(hex: "999999"))
                                
                                Text(viewModel.ageText.isEmpty ? "0" : viewModel.ageText)
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(Color(hex: "9F610D"))
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 100)
                            .background(Color(hex: "F5F7FB"))
                            .cornerRadius(10)
                            
                            // Gender Card
                            VStack(spacing: 6) {
                                Image(systemName: "person.fill")
                                    .font(.system(size: 25))
                                    .foregroundColor(Color(hex: "0D189F"))
                                
                                Text("الجنس")
                                    .font(.system(size: 11))
                                    .foregroundColor(Color(hex: "999999"))
                                
                                Text(viewModel.selectedGender.rawValue.isEmpty ? "لم يتم تحديد" : viewModel.selectedGender.rawValue)
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(Color(hex: "9F610D"))
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 100)
                            .background(Color(hex: "F5F7FB"))
                            .cornerRadius(10)
                            
                            // Hourly Rate Card
                            VStack(spacing: 6) {
                                Image(.ريال)
                                    .renderingMode(.template)
                                    .resizable()
                                    .foregroundColor(Color(hex: "0D189F"))
                                    .frame(width: 25, height: 25)
                                
                                Text("المبلغ / بالساعة")
                                    .font(.system(size: 11))
                                    .foregroundColor(Color(hex: "999999"))
                                
                                Text(viewModel.hourlyRateText.isEmpty ? "0" : viewModel.hourlyRateText)
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(Color(hex: "9F610D"))
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 100)
                            .background(Color(hex: "F5F7FB"))
                            .cornerRadius(10)
                        }
                        .padding(8)
                        
                        // Sign Language Level
                        HStack(spacing: 12) {
                            Image(systemName: "hand.raised.fill")
                                .font(.system(size: 20))
                                .foregroundColor(Color(hex: "0D189F"))
                            
                            Text("المستوى بلغة الإشارة")
                                .font(.system(size: 15))
                                .foregroundColor(.black)
                            
                            HStack(spacing: 16) {
                                ForEach(0..<3, id: \.self) { index in
                                    Image(systemName: "star.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(
                                            index < levelToStars(viewModel.selectedLevel)
                                                ? Color(hex: "9F610D")
                                                : Color(hex: "E0E0E0")
                                        )
                                }
                            }
                            .padding(.trailing, 40)
                        }
                        .frame(height: 60)
                        .frame(maxWidth: .infinity)
                        .background(Color(hex: "F5F7FB"))
                        .cornerRadius(10)
                        .padding(8)
                        
//                        Divider()
//                            .padding(.vertical, 4)
                        
                        // Career Section - Always show
                        HStack(spacing: 0) {
//                            Image(systemName: "briefcase.fill")
//                                .font(.system(size: 20))
//                                .foregroundColor(buttonColor)
//                                .padding(.leading, 10)
                            
                            Text("المجالات")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.black)
                                .padding(.leading, 6)
                            
                            Spacer()
                        }
                        .padding(8)
                        .padding(.bottom, 0)
                        
                        // Display selected careers or default message
                        VStack(alignment: .trailing, spacing: 10) {
                            if viewModel.selectedCareers.isEmpty {
                                HStack(spacing: 8) {
                                    Image(systemName: "briefcase.fill")
                                        .font(.system(size: 14))
                                        .foregroundColor(Color(hex: "0D189F"))
                                    
                                    Text("لم يتم تحديد المجالات بعد")
                                        .font(.system(size: 13))
                                        .foregroundColor(.gray)
                                    
                                    Spacer()
                                }
                                .frame(maxWidth: .infinity)
                                .padding(10)
                                .background(Color(hex: "F5F7FB"))
                                .cornerRadius(8)
                            } else {
                                ForEach(Array(viewModel.selectedCareers).sorted { $0.rawValue < $1.rawValue }, id: \.self) { career in
                                    HStack(spacing: 8) {
                                        Image(systemName: "briefcase.fill")
                                            .font(.system(size: 14))
                                            .foregroundColor(Color(hex: "0D189F"))
                                        
                                        Text(career.rawValue)
                                            .font(.system(size: 13))
                                            .foregroundColor(.black)
                                        
                                        Spacer()
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(10)
                                    .background(Color(hex: "F5F7FB"))
                                    .cornerRadius(8)
                                }
                            }
                        }
                        .padding(16)
                        .padding(.top, 0)
                        
                        // Buttons Section
                        VStack(spacing: 12) {
                            // Edit Button
                            Button(action: {
                                showEditSheet = true
                            }) {
                                Text("تعديل الملف الشخصي")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 48)
                                    .background(Color(hex: "0D189F"))
                                    .cornerRadius(10)
                            }
                            
                            // Delete Button
                            Button(role: .destructive, action: {
                                showDeleteAlert = true
                            }) {
                                HStack {
                                    Image(systemName: "trash")
                                    Text("حذف الملف الشخصي")
                                }
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.red, lineWidth: 1)
                                )
                            }
                        }
                        .padding(16)
                    }
                    .background(.white)
                    .cornerRadius(20)
                    .padding(16)
                }
                
                Spacer()
            }
            
            if showCustomAlert {
                CenteredAlertView(message: alertMessage) {
                    showCustomAlert = false
                }
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
        .onAppear {
            Task { await viewModel.loadUserProfile() }
        }
        .sheet(isPresented: $showEditSheet) {
            TranslatorProfileView(isPresented: $showEditSheet, parentViewModel: viewModel)
                .environment(\.layoutDirection, .rightToLeft)
        }
        .alert("تأكيد الحذف", isPresented: $showDeleteAlert) {
            Button("حذف", role: .destructive) {
                Task {
                    await viewModel.deleteUserProfile()
                    alertMessage = "تم حذف الملف الشخصي بنجاح"
                    showCustomAlert = true
                }
            }
            Button("إلغاء", role: .cancel) { }
        } message: {
            Text("هل أنت متأكد من رغبتك في حذف الملف الشخصي؟")
        }
    }
    
    private func levelToStars(_ level: Level) -> Int {
        switch level {
        case .beginner: return 1
        case .intermediate: return 2
        case .advanced: return 3
        }
    }
}

#Preview {
    MainTranslatorProfileView()
}
