//import SwiftUI
//
//struct DeafHome: View {
//    @EnvironmentObject private var appStateManager: AppStateManager
//    @EnvironmentObject private var authViewModel: AuthViewModel            // 👈 NEW
//    @StateObject private var viewModel = TranslationViewModel()
//    @Environment(\.layoutDirection) var layoutDirection
//    @Binding var deafName: String
//    @State private var hasInitializedUser = false
//    
//    @AppStorage("deafUserId") private var deafUserId: String = ""
//
//    var body: some View {
//        VStack(spacing: 0) {
//            HeaderView(deafName: $deafName)     // Header uses AuthViewModel via EnvironmentObject
//
//            ScrollView(.vertical, showsIndicators: false) {
//                VStack(alignment: .leading, spacing: 16) {
//                    Text("Available Translators")
//                    //Text("المترجمين المتاحين")
//                        .font(.system(size: 20, weight: .bold))
//                        .foregroundColor(.black)
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                        .padding(.top, 40)
//
//                    TranslatorCardsScrollView(viewModel: viewModel)
//
//                    Text("Appointment Requests")
//                    //Text("مترجمي ")
//                        .font(.system(size: 20, weight: .bold))
//                        .foregroundColor(.black)
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                        .padding(.top, 20)
//
//                    if !viewModel.appointmentsWithTranslators.isEmpty {
//                        MyRequestsView(viewModel: viewModel)
//                            .padding(.bottom, 40)
//                    } else {
//                        Text("No appointment requests sent yet")
//                        //Text("لا توجد مترجمين تم التواصل معهم بعد")
//                            .foregroundColor(.gray)
//                    }
//                }
//            }
//        }
//        .padding(.horizontal, 16)
//        .onAppear {
//            // Local UUID used for appointments, kept as is
//            if deafUserId.isEmpty {
//                deafUserId = UUID().uuidString
//                print("Generated new user ID: \(deafUserId)")
//            }
//
//            guard !hasInitializedUser else {
//                print("DeafHome appeared - already initialized")
//                return
//            }
//
//            if !deafName.isEmpty {
//                viewModel.setDeafUser(userId: deafUserId, name: deafName)
//                hasInitializedUser = true
//            } else {
//                print("deafName is empty on appear")
//            }
//        }
//        .onChange(of: deafName) { newName in
//            guard !hasInitializedUser, !newName.isEmpty else { return }
//            viewModel.setDeafUser(userId: deafUserId, name: newName)
//            hasInitializedUser = true
//        }
//        .navigationBarBackButtonHidden(true)
//        .background(Color(hex: "F2F2F2"))
//        .environment(\.layoutDirection, .leftToRight)
//    }
//}
//
//// MARK: - Updated Header View
//struct HeaderView: View {
//    @EnvironmentObject private var appStateManager: AppStateManager
//    @EnvironmentObject private var authViewModel: AuthViewModel
//    @Binding var deafName: String
//    @State private var showDeleteAlert = false
//    @AppStorage("deafUserId") private var deafUserId: String = ""
//
//    var body: some View {
//        HStack {
//            VStack(alignment: .leading, spacing: 4) {
//                Text("Welcome, \(deafName)")
//                //Text("مرحباً, \(deafName)")
//                    .font(.system(size: 18, weight: .semibold))
//                    .foregroundColor(.black)
//            }
//
//            Spacer()
//            HStack (spacing: 24) {
//                NavigationLink {
//                    MessagesView()
//                } label: {
//                    Image(systemName: "bubble.left.and.text.bubble.right")
//                        .font(.system(size: 24))
//                        .foregroundColor(.black)
//                }
//
//                Button {
//                    showDeleteAlert = true
//                } label: {
//                    Image(systemName: "iphone.and.arrow.right.outward")
//                        .font(.system(size: 24))
//                        .foregroundColor(.red)
//                }
//                .alert("Are you sure you want to delete your account?", isPresented: $showDeleteAlert) {
//                    Button("Cancel", role: .cancel) {}
//
//                    Button("Delete Account", role: .destructive) {
//                        // 🔥 Step 1: Delete all appointments first
//                        print("🗑️ Starting cascade deletion for user: \(deafUserId)")
//                        FirebaseService.shared.deleteAllUserAppointments(userId: deafUserId) { result in
//                            switch result {
//                            case .success:
//                                print("✅ All appointments deleted successfully")
//                                
//                                // Step 2: Delete the deaf user account via AuthViewModel
//                                authViewModel.deleteDeafAccount { deleteResult in
//                                    switch deleteResult {
//                                    case .success:
//                                        print("✅ Deaf account deleted from deafUsers")
//                                        deafName = ""
//                                        appStateManager.logout()
//                                    case .failure(let error):
//                                        print("❌ Failed to delete deaf account: \(error.localizedDescription)")
//                                        appStateManager.logout()
//                                    }
//                                }
//                                
//                            case .failure(let error):
//                                print("❌ Failed to delete appointments: \(error.localizedDescription)")
//                                // Still proceed to delete account even if appointments deletion fails
//                                authViewModel.deleteDeafAccount { deleteResult in
//                                    switch deleteResult {
//                                    case .success:
//                                        print("✅ Deaf account deleted from deafUsers")
//                                        deafName = ""
//                                        appStateManager.logout()
//                                    case .failure(let deleteError):
//                                        print("❌ Failed to delete deaf account: \(deleteError.localizedDescription)")
//                                        appStateManager.logout()
//                                    }
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//        }
//        .padding(.vertical, 8)
//        .padding(.top, 32)
//    }
//}
//
//// MARK: - My Requests View
//struct MyRequestsView: View {
//    @ObservedObject var viewModel: TranslationViewModel
//    
//    var body: some View {
//        VStack(spacing: 12) {
//            ForEach(viewModel.appointmentsWithTranslators) { appointmentWithTranslator in
//                if let translator = appointmentWithTranslator.translator {
//                    AppointmentCard(
//                        appointment: appointmentWithTranslator.appointment,
//                        translator: translator,
//                        viewModel: viewModel
//                    )
//                } else {
//                    DeletedTranslatorCard(
//                        appointment: appointmentWithTranslator.appointment,
//                        viewModel: viewModel
//                    )
//                }
//            }
//        }
//    }
//}
//
//// MARK: - Translator Cards Scroll View
//struct TranslatorCardsScrollView: View {
//    @ObservedObject var viewModel: TranslationViewModel
//    @State private var currentPage = 0
//    
//    var body: some View {
//        VStack {
//            if viewModel.isLoading {
//                ProgressView("Loading...")
//                    .frame(height: 180)
//                    .padding(.vertical, 24)
//            } else if let error = viewModel.errorMessage {
//                VStack(spacing: 8) {
//                    Text("Error loading data")
//                        .foregroundColor(.red)
//                    Text(error)
//                        .font(.caption)
//                        .foregroundColor(.gray)
//                    Button("Try Again") {
//                        viewModel.fetchTranslators()
//                    }
//                    .padding(.top, 8)
//                }
//                .frame(height: 180)
//            } else if viewModel.limitedTranslators.isEmpty {
//                Text("No translators available")
//                    .foregroundColor(.gray)
//                    .frame(height: 180)
//            } else {
//                TabView(selection: $currentPage) {
//                    ForEach(Array(viewModel.limitedTranslators.enumerated()), id: \.offset) { index, translator in
//                        TranslatorCard(translator: translator, viewModel: viewModel)
//                            .tag(index)
//                    }
//                    .padding(3)
//            
//                    SeeAllCard(viewModel: viewModel)
//                        .tag(viewModel.limitedTranslators.count)
//                }
//                .tabViewStyle(.page(indexDisplayMode: .never))
//                .frame(height: 180)
//                
//                HStack(spacing: 8) {
//                    ForEach(0...viewModel.limitedTranslators.count, id: \.self) { index in
//                        Circle()
//                            .fill(currentPage == index ? Color(hex: "0D189F") : Color(hex: "D8D8D8"))
//                            .frame(width: currentPage == index ? 10 : 8, height: currentPage == index ? 10 : 8)
//                            .animation(.spring(response: 0.3), value: currentPage)
//                    }
//                }
//            }
//        }
//    }
//}
//
//// MARK: - Common card spacing constants
//private enum CardSpacing {
//    static let horizontalPadding: CGFloat = 20
//    static let verticalPadding: CGFloat = 12
//    static let cardHeight: CGFloat = 150
//    static let dividerHeight: CGFloat = 100
//}
//
//// MARK: - Appointment Card
//struct AppointmentCard: View {
//    let appointment: AppointmentRequest
//    let translator: TranslatorData
//    @ObservedObject var viewModel: TranslationViewModel
//    
//    var body: some View {
//        HStack(spacing: 0) {
//            VStack(alignment: .leading, spacing: 12) {
//                HStack(spacing: 12) {
//                    if translator.gender == "Female" {
//                        Image("femaleIcon")
//                            .resizable()
//                            .renderingMode(.template)
//                            .scaledToFit()
//                            .frame(width: 53, height: 53)
//                            .foregroundColor(Color(hex: "DC7F7F"))
//                    } else {
//                        Image("maleIcon")
//                            .resizable()
//                            .renderingMode(.template)
//                            .scaledToFit()
//                            .frame(width: 48, height: 48)
//                            .foregroundColor(Color(hex: "092B6F"))
//                    }
//                    
//                    VStack(alignment: .leading, spacing: 4) {
//                        Text(translator.name)
//                            .font(.system(size: 18, weight: .semibold))
//                            .foregroundColor(Color(hex: "1A1A1A"))
//                            .lineLimit(2)
//                            .fixedSize(horizontal: false, vertical: true)
//                            .layoutPriority(1)
//                        
//                        HStack(spacing: 6) {
//                            Circle()
//                                .fill(translator.category == "متطوع" ? Color(hex: "5CB853") : Color(hex: "EBA0A0"))
//                                .frame(width: 6, height: 6)
//                            
//                            Text(translator.category == "متطوع" ? "Volunteer" : "Paid")
//                                .font(.system(size: 13, weight: .medium))
//                                .foregroundColor(translator.category == "متطوع" ? Color(hex: "5CB853") : Color(hex: "EBA0A0"))
//                        }
//                    }
//                }
//                
//                HStack(spacing: 8) {
//                    TagView(text: translator.age, icon: "calendar")
//                    TagView(text: translator.level, icon: "star.fill")
//                }
//            }
//            .padding(.leading, CardSpacing.horizontalPadding)
//            .padding(.trailing, CardSpacing.horizontalPadding / 2)
//            
//            Rectangle()
//                .fill(
//                    LinearGradient(
//                        colors: [
//                            Color(hex: "E0E0E0").opacity(0.3),
//                            Color(hex: "E0E0E0"),
//                            Color(hex: "E0E0E0").opacity(0.3)
//                        ],
//                        startPoint: .top,
//                        endPoint: .bottom
//                    )
//                )
//                .frame(width: 1, height: CardSpacing.dividerHeight)
//            
//            VStack(spacing: 8) {
//                VStack(spacing: 2) {
//                    HStack(spacing: 4) {
//                        Text(translator.price)
//                            .font(.system(size: 28, weight: .bold))
//                            .foregroundColor(Color(hex: "0D189F"))
//                        
//                        Image(.ريال)
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 22, height: 22)
//                    }
//                    
//                    Text("Per Hour")
//                        .font(.system(size: 12, weight: .medium))
//                        .foregroundColor(Color(hex: "9E9E9E"))
//                }
//                
//                Button {
//                    if let appointmentId = appointment.id {
//                        print("Cancel button pressed for: \(appointmentId)")
//                        viewModel.cancelAppointment(appointmentId: appointmentId)
//                    } else {
//                        print("Appointment ID is nil!")
//                    }
//                } label: {
//                    HStack {
//                        Image(systemName: "xmark.circle.fill")
//                        Text("Cancel")
//                    }
//                    .foregroundColor(.white)
//                    .font(.system(size: 14, weight: .semibold))
//                    .frame(width: 110, height: 42)
//                    .background(
//                        LinearGradient(
//                            colors: [Color.red, Color.red.opacity(0.8)],
//                            startPoint: .topLeading,
//                            endPoint: .bottomTrailing
//                        )
//                    )
//                    .cornerRadius(14)
//                    .shadow(color: Color.red.opacity(0.3), radius: 8, x: 0, y: 4)
//                }
//            }
//            .frame(minWidth: 120, alignment: .trailing)
//            .padding(.trailing, CardSpacing.horizontalPadding)
//            .padding(.leading, CardSpacing.horizontalPadding / 2)
//        }
//        .frame(maxWidth: .infinity)
//        .frame(height: CardSpacing.cardHeight)
//        .background(
//            RoundedRectangle(cornerRadius: 24)
//                .fill(Color.white)
//                .shadow(color: .black.opacity(0.04), radius: 12, x: 0, y: 4)
//                .overlay(
//                    RoundedRectangle(cornerRadius: 24)
//                        .stroke(Color(hex: "F5F5F5"), lineWidth: 1)
//                )
//        )
//    }
//}
//
//// MARK: - Deleted Translator Card
//struct DeletedTranslatorCard: View {
//    let appointment: AppointmentRequest
//    @ObservedObject var viewModel: TranslationViewModel
//    
//    var body: some View {
//        HStack(spacing: 0) {
//            VStack(alignment: .leading, spacing: 12) {
//                HStack(spacing: 12) {
//                    Image(systemName: "person.fill.xmark")
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 48, height: 48)
//                        .foregroundColor(.gray)
//                    
//                    VStack(alignment: .leading, spacing: 4) {
//                        Text("Translator Unavailable")
//                            .font(.system(size: 18, weight: .semibold))
//                            .foregroundColor(Color(hex: "1A1A1A"))
//                        
//                        Text("This translator is no longer available")
//                            .font(.system(size: 13, weight: .medium))
//                            .foregroundColor(.gray)
//                    }
//                }
//            }
//            .padding(.leading, CardSpacing.horizontalPadding)
//            .padding(.trailing, CardSpacing.horizontalPadding / 2)
//            
//            Spacer()
//            
//            VStack(spacing: 8) {
//                Button {
//                    if let appointmentId = appointment.id {
//                        viewModel.cancelAppointment(appointmentId: appointmentId)
//                    }
//                } label: {
//                    HStack {
//                        Image(systemName: "trash.fill")
//                        Text("Remove")
//                    }
//                    .foregroundColor(.white)
//                    .font(.system(size: 14, weight: .semibold))
//                    .frame(width: 110, height: 42)
//                    .background(Color.gray)
//                    .cornerRadius(14)
//                }
//            }
//            .frame(minWidth: 120, alignment: .trailing)
//            .padding(.trailing, CardSpacing.horizontalPadding)
//            .padding(.leading, CardSpacing.horizontalPadding / 2)
//        }
//        .frame(maxWidth: .infinity)
//        .frame(height: CardSpacing.cardHeight)
//        .background(
//            RoundedRectangle(cornerRadius: 24)
//                .fill(Color.white.opacity(0.6))
//                .shadow(color: .black.opacity(0.04), radius: 12, x: 0, y: 4)
//                .overlay(
//                    RoundedRectangle(cornerRadius: 24)
//                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
//                )
//        )
//        .padding(.vertical, CardSpacing.verticalPadding)
//    }
//}
//
//// MARK: - Translator Card
//struct TranslatorCard: View {
//    let translator: TranslatorData
//    @ObservedObject var viewModel: TranslationViewModel
//    @State private var showRequistSheet = false
//    @State private var showDuplicateAlert = false
//
//    var body: some View {
//        HStack(spacing: 0) {
//            VStack(alignment: .leading, spacing: 16) {
//                HStack(spacing: 12) {
//                    if translator.gender == "Female" {
//                        Image("femaleIcon")
//                            .resizable()
//                            .renderingMode(.template)
//                            .scaledToFit()
//                            .frame(width: 53, height: 53)
//                            .foregroundColor(Color(hex: "DC7F7F"))
//                    } else {
//                        Image("maleIcon")
//                            .resizable()
//                            .renderingMode(.template)
//                            .scaledToFit()
//                            .frame(width: 48, height: 48)
//                            .foregroundColor(Color(hex: "092B6F"))
//                    }
//                    
//                    VStack(alignment: .leading, spacing: 4) {
//                        Text(translator.name)
//                            .font(.system(size: 18, weight: .semibold))
//                            .foregroundColor(Color(hex: "1A1A1A"))
//                            .lineLimit(2)
//                            .fixedSize(horizontal: false, vertical: true)
//                            .layoutPriority(1)
//                        
//                        HStack(spacing: 6) {
//                            Circle()
//                                .fill(translator.state == "متطوع" ? Color(hex: "5CB853") : Color(hex: "EBA0A0"))
//                                .frame(width: 6, height: 6)
//                            
//                            Text(translator.state == "متطوع" ? "Volunteer" : "Paid")
//                                .font(.system(size: 13, weight: .medium))
//                                .foregroundColor(translator.state == "متطوع" ? Color(hex: "5CB853") : Color(hex: "EBA0A0"))
//                        }
//                    }
//                }
//                
//                HStack(spacing: 8) {
//                    TagView(text: translator.age, icon: "calendar")
//                    TagView(text: translator.level, icon: "star.fill")
//                }
//            }
//            .padding(.leading, CardSpacing.horizontalPadding)
//            .padding(.trailing, CardSpacing.horizontalPadding / 2)
//            
//            Rectangle()
//                .fill(
//                    LinearGradient(
//                        colors: [
//                            Color(hex: "E0E0E0").opacity(0.3),
//                            Color(hex: "E0E0E0"),
//                            Color(hex: "E0E0E0").opacity(0.3)
//                        ],
//                        startPoint: .top,
//                        endPoint: .bottom
//                    )
//                )
//                .frame(width: 1, height: CardSpacing.dividerHeight)
//            
//            VStack(spacing: 8) {
//                VStack(spacing: 2) {
//                    HStack(spacing: 4) {
//                        Text(translator.price)
//                            .font(.system(size: 28, weight: .bold))
//                            .foregroundColor(Color(hex: "0D189F"))
//                        
//                        Image(.ريال)
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 22, height: 22)
//                    }
//                    
//                    Text("Per Hour")
//                        .font(.system(size: 12, weight: .medium))
//                        .foregroundColor(Color(hex: "9E9E9E"))
//                }
//                
//                VStack {
//                    Button {
//                        if viewModel.appointments.contains(where: { $0.translatorId == translator.id }) {
//                            showDuplicateAlert = true
//                        } else {
//                            showRequistSheet = true
//                        }
//                    } label: {
//                        HStack {
//                            Text("Contact")
//                                .foregroundColor(.white)
//                                .font(.system(size: 14, weight: .semibold))
//                        }
//                        .frame(width: 110, height: 42)
//                        .background(
//                            LinearGradient(
//                                colors: [Color(hex: "0D189F"), Color(hex: "0A1280")],
//                                startPoint: .topLeading,
//                                endPoint: .bottomTrailing
//                            )
//                        )
//                        .cornerRadius(14)
//                        .shadow(color: Color(hex: "0D189F").opacity(0.3), radius: 8, x: 0, y: 4)
//                    }
//                    .alert("You already requested this translator!", isPresented: $showDuplicateAlert) {
//                        Button("OK", role: .cancel) {}
//                    }
//                }
//                .sheet(isPresented: $showRequistSheet) {
//                    RequistSheet(translator: translator, viewModel: viewModel)
//                        .presentationDetents([.medium, .large])
//                        .presentationDragIndicator(.hidden)
//                }
//            }
//            .frame(minWidth: 120, alignment: .trailing)
//            .padding(.trailing, CardSpacing.horizontalPadding)
//            .padding(.leading, CardSpacing.horizontalPadding / 2)
//        }
//        .frame(maxWidth: .infinity)
//        .frame(height: CardSpacing.cardHeight)
//        .background(
//            RoundedRectangle(cornerRadius: 24)
//                .fill(Color.white)
//                .shadow(color: .black.opacity(0.04), radius: 12, x: 0, y: 4)
//                .overlay(
//                    RoundedRectangle(cornerRadius: 24)
//                        .stroke(Color(hex: "F5F5F5"), lineWidth: 1)
//                )
//        )
//        .padding(.vertical, CardSpacing.verticalPadding)
//    }
//}
//
//// MARK: - Tag View
//struct TagView: View {
//    let text: String
//    let icon: String
//    
//    var body: some View {
//        HStack(spacing: 4) {
//            Image(systemName: icon)
//                .font(.system(size: 11, weight: .medium))
//                .foregroundColor(Color(hex: "666666"))
//            
//            Text(text)
//                .font(.system(size: 13, weight: .medium))
//                .foregroundColor(Color(hex: "666666"))
//        }
//        .padding(.horizontal, 10)
//        .padding(.vertical, 6)
//        .background(
//            RoundedRectangle(cornerRadius: 8)
//                .fill(Color(hex: "F8F8F8"))
//                .overlay(
//                    RoundedRectangle(cornerRadius: 8)
//                        .stroke(Color(hex: "EEEEEE"), lineWidth: 1)
//                )
//        )
//    }
//}
//
//// MARK: - See All Card
//struct SeeAllCard: View {
//    @ObservedObject var viewModel: TranslationViewModel
//    
//    var body: some View {
//        NavigationLink {
//            AllTranslatorsView(viewModel: viewModel)
//        } label: {
//            HStack(spacing: 16) {
//                Text("See All")
//                    .font(.system(size: 22, weight: .bold))
//                    .foregroundColor(Color(hex: "1A1A1A"))
//                
//                Image(systemName: "arrow.right")
//                    .font(.system(size: 40, weight: .semibold))
//                    .foregroundColor(Color(hex: "0D189F"))
//            }
//            .frame(height: 160)
//            .frame(maxWidth: .infinity)
//            .background(
//                RoundedRectangle(cornerRadius: 24)
//                    .fill(Color.white)
//                    .shadow(color: .black.opacity(0.04), radius: 12, x: 0, y: 4)
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 24)
//                            .stroke(Color(hex: "F5F5F5"), lineWidth: 1)
//                    )
//            )
//            .padding(.vertical, 8)
//        }
//    }
//}
//
//// MARK: - Color Extension
//extension Color {
//    init(hex: String) {
//        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
//        var int: UInt64 = 0
//        Scanner(string: hex).scanHexInt64(&int)
//        let a, r, g, b: UInt64
//        switch hex.count {
//        case 3:
//            (a, r, g, b) = (255,
//                            (int >> 8) * 17,
//                            (int >> 4 & 0xF) * 17,
//                            (int & 0xF) * 17)
//        case 6:
//            (a, r, g, b) = (255,
//                            int >> 16,
//                            int >> 8 & 0xFF,
//                            int & 0xFF)
//        case 8:
//            (a, r, g, b) = (int >> 24,
//                            int >> 16 & 0xFF,
//                            int >> 8 & 0xFF,
//                            int & 0xFF)
//        default:
//            (a, r, g, b) = (255, 255, 255, 255)
//        }
//
//        self.init(
//            .sRGB,
//            red: Double(r) / 255,
//            green: Double(g) / 255,
//            blue:  Double(b) / 255,
//            opacity: Double(a) / 255)
//    }
//}
//
//// MARK: - Preview
//#Preview {
//    NavigationStack {
//        DeafHome(deafName: .constant("User"))
//            .environmentObject(AppStateManager())
//            .environmentObject(AuthViewModel())   // ✅ add this
//    }
//}


import SwiftUI

struct DeafHome: View {
    @EnvironmentObject private var appStateManager: AppStateManager
    @EnvironmentObject private var authViewModel: AuthViewModel            // 👈 NEW
    @StateObject private var viewModel = TranslationViewModel()
    @Environment(\.layoutDirection) var layoutDirection
    @Binding var deafName: String
    @State private var hasInitializedUser = false
    @State private var isHelp: Bool = false

    @AppStorage("deafUserId") private var deafUserId: String = ""
    
    // UI only
    @State private var floatingPulse = false

    var body: some View {
        ZStack {
            // subtle two-tone background
            LinearGradient(gradient: Gradient(colors: [Color(hex: "F7F9FF"), Color(hex: "F2F6FF")]),
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                HeaderView(deafName: $deafName) // name unchanged
                    .padding(.horizontal, 16)
                    .padding(.bottom, 6)
                    // soft rounded rectangle behind header for depth
                    .background(
                        RoundedRectangle(cornerRadius: 28)
                            .fill(Color.white.opacity(0.0001))
                            .shadow(color: Color.black.opacity(0.02), radius: 8, x: 0, y: 6)
                    )

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Available Translators")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Color(hex: "0B1A66"))
                            .padding(.top, 18)

                        TranslatorCardsScrollView(viewModel: viewModel)

                        Text("Appointment Requests")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Color(hex: "0B1A66"))
                            .padding(.top, 8)

                        if !viewModel.appointmentsWithTranslators.isEmpty {
                            MyRequestsView(viewModel: viewModel)
                                .padding(.bottom, 40)
                        } else {
                            Text("No appointment requests sent yet")
                                .foregroundColor(.gray)
                                .padding(.vertical, 12)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 120)
                }
            }

            // help button (inside DeafHome body)
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        isHelp = true
                    } label: {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(LinearGradient(gradient: Gradient(colors: [Color(hex: "0D189F"), Color(hex: "0A1280")]), startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 64, height: 64)
                            .shadow(color: Color(hex: "0D189F").opacity(0.22), radius: 14, x: 0, y: 8)
                            .overlay(
                                VStack(spacing: 0) {
                                    Image(systemName: "hand.raised.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(.white)
                                    Text("Help")
                                        .font(.system(size: 10, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                            )
                    }
                    .buttonStyle(.plain) // prevents default button styling
                    .sheet(isPresented: $isHelp) {
                        HelpSheet() // your sheet view
                    }
                    .padding()
                }
            }

        }
        .onAppear {
            if deafUserId.isEmpty {
                deafUserId = UUID().uuidString
                print("Generated new user ID: \(deafUserId)")
            }

            guard !hasInitializedUser else {
                print("DeafHome appeared - already initialized")
                return
            }

            if !deafName.isEmpty {
                viewModel.setDeafUser(userId: deafUserId, name: deafName)
                hasInitializedUser = true
            } else {
                print("deafName is empty on appear")
            }
        }
        .onChange(of: deafName) { newName in
            guard !hasInitializedUser, !newName.isEmpty else { return }
            viewModel.setDeafUser(userId: deafUserId, name: newName)
            hasInitializedUser = true
        }
        .navigationBarBackButtonHidden(true)
        .environment(\.layoutDirection, .leftToRight)
    }
}

// MARK: - Updated Header View (same name)
struct HeaderView: View {
    @EnvironmentObject private var appStateManager: AppStateManager
    @EnvironmentObject private var authViewModel: AuthViewModel
    @Binding var deafName: String
    @State private var showDeleteAlert = false
    @AppStorage("deafUserId") private var deafUserId: String = ""

    // UI-only pulse
    @State private var pulse = false

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Welcome,")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Color(hex: "666666"))

                Text(deafName.isEmpty ? "Our User" : deafName)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Color(hex: "0B1A66"))
            }

            Spacer()

            HStack (spacing: 24) {
                NavigationLink {
//                    MessagesView()
                    LiveChatView(
                        currentUserId: "user123",
                        currentUserName: "Me",
                        recipientUserId: "user456",
                        recipientName: "John Doe",
                        recipientContact: "+966501234567"
                    )

                    
                } label: {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "bubble.left.and.text.bubble.right")
                            .font(.system(size: 24))
                            .foregroundColor(Color(hex: "0B1A66"))
//                        Circle()
//                            .fill(Color.red)
//                            .frame(width: 8, height: 8)
//                            .offset(x: 10, y: -8)
//                            .opacity(0.95)
                    }
                }

                Button {
                    showDeleteAlert = true
                } label: {
                    Image(systemName: "iphone.and.arrow.right.outward")
                        .font(.system(size: 24))
                        .foregroundColor(.red)
                }
                .alert("Are you sure you want to delete your account?", isPresented: $showDeleteAlert) {
                    Button("Cancel", role: .cancel) {}

                    Button("Delete Account", role: .destructive) {
                        // 🔥 Step 1: Delete all appointments first
                        print("🗑️ Starting cascade deletion for user: \(deafUserId)")
                        FirebaseService.shared.deleteAllUserAppointments(userId: deafUserId) { result in
                            switch result {
                            case .success:
                                print("✅ All appointments deleted successfully")
                                
                                // Step 2: Delete the deaf user account via AuthViewModel
                                authViewModel.deleteDeafAccount { deleteResult in
                                    switch deleteResult {
                                    case .success:
                                        print("✅ Deaf account deleted from deafUsers")
                                        deafName = ""
                                        appStateManager.logout()
                                    case .failure(let error):
                                        print("❌ Failed to delete deaf account: \(error.localizedDescription)")
                                        appStateManager.logout()
                                    }
                                }
                                
                            case .failure(let error):
                                print("❌ Failed to delete appointments: \(error.localizedDescription)")
                                // Still proceed to delete account even if appointments deletion fails
                                authViewModel.deleteDeafAccount { deleteResult in
                                    switch deleteResult {
                                    case .success:
                                        print("✅ Deaf account deleted from deafUsers")
                                        deafName = ""
                                        appStateManager.logout()
                                    case .failure(let deleteError):
                                        print("❌ Failed to delete deaf account: \(deleteError.localizedDescription)")
                                        appStateManager.logout()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.top, 32)
    }
}

// MARK: - My Requests View (same name)
struct MyRequestsView: View {
    @ObservedObject var viewModel: TranslationViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(viewModel.appointmentsWithTranslators) { appointmentWithTranslator in
                if let translator = appointmentWithTranslator.translator {
                    AppointmentCard(
                        appointment: appointmentWithTranslator.appointment,
                        translator: translator,
                        viewModel: viewModel
                    )
                } else {
                    DeletedTranslatorCard(
                        appointment: appointmentWithTranslator.appointment,
                        viewModel: viewModel
                    )
                }
            }
        }
    }
}

// MARK: - Translator Cards Scroll View (same name)
// Implemented shimmer-like loading inline using state and gradient overlay (no new types)
struct TranslatorCardsScrollView: View {
    @ObservedObject var viewModel: TranslationViewModel
    @State private var currentPage = 0
    @State private var shimmerPhase: CGFloat = -1

    var body: some View {
        VStack {
            if viewModel.isLoading {
                // shimmer placeholder without new types
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .frame(height: 160)
                    .overlay(
                        LinearGradient(gradient: Gradient(stops: [
                            .init(color: Color.white.opacity(0.0), location: 0),
                            .init(color: Color.white.opacity(0.7), location: 0.5),
                            .init(color: Color.white.opacity(0.0), location: 1),
                        ]), startPoint: .leading, endPoint: .trailing)
                        .rotationEffect(.degrees(20))
                        .offset(x: shimmerPhase)
                        .blendMode(.overlay)
                    )
                    .shadow(color: .black.opacity(0.03), radius: 10, x: 0, y: 6)
                    .onAppear {
                        withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) {
                            shimmerPhase = 600
                        }
                    }
                    .padding(.vertical, 6)
            } else if let error = viewModel.errorMessage {
                VStack(spacing: 8) {
                    Text("Error loading data")
                        .foregroundColor(.red)
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.gray)
                    Button("Try Again") {
                        viewModel.fetchTranslators()
                    }
                    .padding(.top, 8)
                }
                .frame(height: 180)
            } else if viewModel.limitedTranslators.isEmpty {
                Text("No translators available")
                    .foregroundColor(.gray)
                    .frame(height: 180)
            } else {
                TabView(selection: $currentPage) {
                    ForEach(Array(viewModel.limitedTranslators.enumerated()), id: \.offset) { index, translator in
                        TranslatorCard(translator: translator, viewModel: viewModel)
                            .tag(index)
                    }
                    SeeAllCard(viewModel: viewModel)
                        .tag(viewModel.limitedTranslators.count)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 180)

                HStack(spacing: 8) {
                    ForEach(0...viewModel.limitedTranslators.count, id: \.self) { index in
                        Capsule()
                            .fill(currentPage == index ? Color(hex: "0D189F") : Color(hex: "D8D8D8"))
                            .frame(width: currentPage == index ? 26 : 8, height: 8)
                            .animation(.spring(), value: currentPage)
                    }
                }
            }
        }
    }
}

// MARK: - Common card spacing constants (unchanged)
private enum CardSpacing {
    static let horizontalPadding: CGFloat = 20
    static let verticalPadding: CGFloat = 12
    static let cardHeight: CGFloat = 150
    static let dividerHeight: CGFloat = 100
}

// MARK: - Appointment Card (same name)
struct AppointmentCard: View {
    let appointment: AppointmentRequest
    let translator: TranslatorData
    @ObservedObject var viewModel: TranslationViewModel
    @State private var pressed = false

    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    if translator.gender == "Female" {
                        Image("femaleIcon")
                            .resizable()
                            .renderingMode(.template)
                            .scaledToFit()
                            .frame(width: 53, height: 53)
                            .foregroundColor(Color(hex: "DC7F7F"))
                    } else {
                        Image("maleIcon")
                            .resizable()
                            .renderingMode(.template)
                            .scaledToFit()
                            .frame(width: 48, height: 48)
                            .foregroundColor(Color(hex: "092B6F"))
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(translator.name)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color(hex: "1A1A1A"))
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                            .layoutPriority(1)
                        
                        HStack(spacing: 6) {
                            Circle()
                                .fill(translator.category == "متطوع" ? Color(hex: "5CB853") : Color(hex: "EBA0A0"))
                                .frame(width: 6, height: 6)
                            
                            Text(translator.category == "متطوع" ? "Volunteer" : "Paid")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(translator.category == "متطوع" ? Color(hex: "5CB853") : Color(hex: "EBA0A0"))
                        }
                    }
                }
                
                HStack(spacing: 8) {
                    TagView(text: translator.age, icon: "calendar")
                    TagView(text: translator.level, icon: "star.fill")
                }
            }
            .padding(.leading, CardSpacing.horizontalPadding)
            .padding(.trailing, CardSpacing.horizontalPadding / 2)
            
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: "E0E0E0").opacity(0.3),
                            Color(hex: "E0E0E0"),
                            Color(hex: "E0E0E0").opacity(0.3)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 1, height: CardSpacing.dividerHeight)
            
            VStack(spacing: 8) {
                VStack(spacing: 2) {
                    HStack(spacing: 4) {
                        Text(translator.price)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(Color(hex: "0D189F"))
                        
                        Image(.ريال)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 22, height: 22)
                    }
                    
                    Text("Per Hour")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color(hex: "9E9E9E"))
                }
                
                Button {
                    if let appointmentId = appointment.id {
                        print("Cancel button pressed for: \(appointmentId)")
                        viewModel.cancelAppointment(appointmentId: appointmentId)
                    } else {
                        print("Appointment ID is nil!")
                    }
                } label: {
                    HStack {
                        Image(systemName: "xmark.circle.fill")
                        Text("Cancel")
                    }
                    .foregroundColor(.white)
                    .font(.system(size: 14, weight: .semibold))
                    .frame(width: 110, height: 42)
                    .background(
                        LinearGradient(
                            colors: [Color.red, Color.red.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(14)
                    .shadow(color: Color.red.opacity(0.3), radius: 8, x: 0, y: 4)
                }
            }
            .frame(minWidth: 120, alignment: .trailing)
            .padding(.trailing, CardSpacing.horizontalPadding)
            .padding(.leading, CardSpacing.horizontalPadding / 2)
        }
        .frame(maxWidth: .infinity)
        .frame(height: CardSpacing.cardHeight)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.04), radius: 12, x: 0, y: 4)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color(hex: "F5F5F5"), lineWidth: 1)
                )
        )
        .padding(.vertical, CardSpacing.verticalPadding)
        .scaleEffect(pressed ? 0.995 : 1.0)
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                pressed.toggle()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) { pressed = false }
            }
        }
    }
}

// MARK: - Deleted Translator Card (same name)
struct DeletedTranslatorCard: View {
    let appointment: AppointmentRequest
    @ObservedObject var viewModel: TranslationViewModel
    
    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    Image(systemName: "person.fill.xmark")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 48, height: 48)
                        .foregroundColor(.gray)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Translator Unavailable")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color(hex: "1A1A1A"))
                        
                        Text("This translator is no longer available")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.leading, CardSpacing.horizontalPadding)
            .padding(.trailing, CardSpacing.horizontalPadding / 2)
            
            Spacer()
            
            VStack(spacing: 8) {
                Button {
                    if let appointmentId = appointment.id {
                        viewModel.cancelAppointment(appointmentId: appointmentId)
                    }
                } label: {
                    HStack {
                        Image(systemName: "trash.fill")
                        Text("Remove")
                    }
                    .foregroundColor(.white)
                    .font(.system(size: 14, weight: .semibold))
                    .frame(width: 110, height: 42)
                    .background(Color.gray)
                    .cornerRadius(14)
                }
            }
            .frame(minWidth: 120, alignment: .trailing)
            .padding(.trailing, CardSpacing.horizontalPadding)
            .padding(.leading, CardSpacing.horizontalPadding / 2)
        }
        .frame(maxWidth: .infinity)
        .frame(height: CardSpacing.cardHeight)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white.opacity(0.6))
                .shadow(color: .black.opacity(0.04), radius: 12, x: 0, y: 4)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
        )
        .padding(.vertical, CardSpacing.verticalPadding)
    }
}

// MARK: - Translator Card (same name)
struct TranslatorCard: View {
    let translator: TranslatorData
    @ObservedObject var viewModel: TranslationViewModel
    @State private var showRequistSheet = false
    @State private var showDuplicateAlert = false
    @State private var pressed = false

    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 12) {
                    if translator.gender == "Female" {
                        Image("femaleIcon")
                            .resizable()
                            .renderingMode(.template)
                            .scaledToFit()
                            .frame(width: 53, height: 53)
                            .foregroundColor(Color(hex: "DC7F7F"))
                    } else {
                        Image("maleIcon")
                            .resizable()
                            .renderingMode(.template)
                            .scaledToFit()
                            .frame(width: 48, height: 48)
                            .foregroundColor(Color(hex: "092B6F"))
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(translator.name)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color(hex: "1A1A1A"))
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                            .layoutPriority(1)
                        
                        HStack(spacing: 6) {
                            Circle()
                                .fill(translator.state == "متطوع" ? Color(hex: "5CB853") : Color(hex: "EBA0A0"))
                                .frame(width: 6, height: 6)
                            
                            Text(translator.state == "متطوع" ? "Volunteer" : "Paid")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(translator.state == "متطوع" ? Color(hex: "5CB853") : Color(hex: "EBA0A0"))
                        }
                    }
                }
                
                HStack(spacing: 8) {
                    TagView(text: translator.age, icon: "calendar")
                    TagView(text: translator.level, icon: "star.fill")
                }
            }
            .padding(.leading, CardSpacing.horizontalPadding)
            .padding(.trailing, CardSpacing.horizontalPadding / 2)
            
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: "E0E0E0").opacity(0.3),
                            Color(hex: "E0E0E0"),
                            Color(hex: "E0E0E0").opacity(0.3)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 1, height: CardSpacing.dividerHeight)
            
            VStack(spacing: 8) {
                VStack(spacing: 2) {
                    HStack(spacing: 4) {
                        Text(translator.price)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(Color(hex: "0D189F"))
                        
                        Image(.ريال)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 22, height: 22)
                    }
                    
                    Text("Per Hour")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color(hex: "9E9E9E"))
                }
                
                VStack {
                    Button {
                        if viewModel.appointments.contains(where: { $0.translatorId == translator.id }) {
                            showDuplicateAlert = true
                        } else {
                            showRequistSheet = true
                        }
                    } label: {
                        HStack {
                            Text("Contact")
                                .foregroundColor(.white)
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .frame(width: 110, height: 42)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "0D189F"), Color(hex: "0A1280")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(14)
                        .shadow(color: Color(hex: "0D189F").opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .alert("You already requested this translator!", isPresented: $showDuplicateAlert) {
                        Button("OK", role: .cancel) {}
                    }
                }
                .sheet(isPresented: $showRequistSheet) {
                    RequistSheet(translator: translator, viewModel: viewModel)
                        .presentationDetents([.medium, .large])
                        .presentationDragIndicator(.hidden)
                }
            }
            .frame(minWidth: 120, alignment: .trailing)
            .padding(.trailing, CardSpacing.horizontalPadding)
            .padding(.leading, CardSpacing.horizontalPadding / 2)
        }
        .frame(maxWidth: .infinity)
        .frame(height: CardSpacing.cardHeight)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.04), radius: 12, x: 0, y: 4)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color(hex: "F5F5F5"), lineWidth: 1)
                )
        )
        .padding(.vertical, CardSpacing.verticalPadding)
        .scaleEffect(pressed ? 0.995 : 1.0)
        .onTapGesture {
            withAnimation(.spring(response: 0.28, dampingFraction: 0.75)) {
                pressed.toggle()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) { pressed = false }
            }
        }
    }
}

// MARK: - Tag View (same name)
struct TagView: View {
    let text: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(Color(hex: "666666"))
            
            Text(text)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Color(hex: "666666"))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(hex: "F8F8F8"))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(hex: "EEEEEE"), lineWidth: 1)
                )
        )
    }
}

// MARK: - See All Card (same name)
struct SeeAllCard: View {
    @ObservedObject var viewModel: TranslationViewModel
    
    var body: some View {
        NavigationLink {
            AllTranslatorsView(viewModel: viewModel)
        } label: {
            HStack(spacing: 16) {
                Text("See All")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(Color(hex: "1A1A1A"))
                
                Image(systemName: "arrow.right")
                    .font(.system(size: 40, weight: .semibold))
                    .foregroundColor(Color(hex: "0D189F"))
            }
            .frame(maxWidth: .infinity)
            .frame(height: CardSpacing.cardHeight)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.04), radius: 12, x: 0, y: 4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color(hex: "F5F5F5"), lineWidth: 1)
                    )
            )
            .padding(.vertical, 8)
        }
    }
}

// MARK: - Color Extension (unchanged)
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255,
                            (int >> 8) * 17,
                            (int >> 4 & 0xF) * 17,
                            (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255,
                            int >> 16,
                            int >> 8 & 0xFF,
                            int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24,
                            int >> 16 & 0xFF,
                            int >> 8 & 0xFF,
                            int & 0xFF)
        default:
            (a, r, g, b) = (255, 255, 255, 255)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255)
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        DeafHome(deafName: .constant("User"))
            .environmentObject(AppStateManager())
            .environmentObject(AuthViewModel())
    }
}
