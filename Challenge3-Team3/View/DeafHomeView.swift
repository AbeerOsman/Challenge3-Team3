//
//  ContentView.swift
//  Challenge3Team3
//
//  Created by Abeer Jeilani Osman  on 29/05/1447 AH.
//

import SwiftUI

struct DeafHome: View {
    @StateObject private var viewModel = TranslationViewModel()
    @Environment(\.layoutDirection) var layoutDirection
    @Binding var deafName: String
    
    // ✨ Use @AppStorage to persist user ID
    @AppStorage("deafUserId") private var deafUserId: String = ""

    var body: some View {
        VStack(spacing: 0) {
            HeaderView(deafName: $deafName)

            ScrollView(.vertical, showsIndicators: true) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Available Translators")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .padding(.top, 20)

                    TranslatorCardsScrollView(viewModel: viewModel)

                    Text("Appointment Requests")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    
                    if !viewModel.appointments.isEmpty {
                        MyRequestsView(viewModel: viewModel)
                            .padding(.horizontal, 8)
                            .padding(.bottom, 40)
                    } else {
                        Text("No appointment requests sent yet")
                            .foregroundColor(.gray)
                            .padding(16)
                    }
                }
            }
        }
        .onAppear {
            print("🏠 DeafHome appeared")
            print("   deafName from binding: '\(deafName)'")
            print("   deafUserId from AppStorage: '\(deafUserId)'")
            
            // If no user ID exists, create one
            if deafUserId.isEmpty {
                deafUserId = UUID().uuidString
                print("Generated new user ID: \(deafUserId)")
            }
            
            // ALWAYS set user info when view appears
            if !deafName.isEmpty {
                print("Setting user in ViewModel:")
                print("ID: \(deafUserId)")
                print("Name: \(deafName)")
                viewModel.setDeafUser(userId: deafUserId, name: deafName)
            } else {
                print("deafName is empty!")
            }
        }
        .navigationBarBackButtonHidden(true)
        .background(Color(hex: "F2F2F2"))
        .environment(\.layoutDirection, .leftToRight)
    }
}

// MARK: - Header View
struct HeaderView: View {
    @Binding var deafName: String
    @State private var showLogoutAlert = false
    @State private var goToSplash = false

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Hello, \(deafName)")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.black)
                
                Text("Always with you, book your translator when you need")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            .padding(.leading, 20)
            
            Spacer()
            
            NavigationLink {
                MessagesView()
            } label: {
                VStack(spacing: 4) {
                    Image(systemName: "bubble.left.and.text.bubble.right")
                        .font(.system(size: 24))
                    Text("Messages")
                        .font(.system(size: 13))
                }
                .foregroundColor(.black)
                .padding(.trailing, 20)
            }

            NavigationLink(destination: ChoiceView(), isActive: $goToSplash) {
                EmptyView()
            }

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
        }
        .padding(.vertical, 16)
        .padding(.top, 40)
    }
}

// MARK: - Filter Button
struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13))
                .foregroundColor(isSelected ? Color(hex: "0D189F") : .gray)
                .padding(.horizontal, 24)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isSelected ? Color(hex: "D8D8D8") : .white)
                        .frame(width: 100, height: 35)
                )
        }
    }
}

// MARK: - My Requests View
struct MyRequestsView: View {
    @ObservedObject var viewModel: TranslationViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(viewModel.appointments) { appointment in
                AppointmentCard(appointment: appointment, viewModel: viewModel) // ✅ Correct
            }
        }
    }
}

// MARK: - Translator Cards Scroll View
struct TranslatorCardsScrollView: View {
    @ObservedObject var viewModel: TranslationViewModel
    @State private var currentPage = 0
    
    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView("Loading...")
                    .frame(height: 180)
                    .padding(24)
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
                        Circle()
                            .fill(currentPage == index ? Color(hex: "0D189F") : Color(hex: "D8D8D8"))
                            .frame(width: currentPage == index ? 10 : 8, height: currentPage == index ? 10 : 8)
                            .animation(.spring(response: 0.3), value: currentPage)
                    }
                }
            }
        }
    }
}

// MARK: - Appointment Card
struct AppointmentCard: View {
    let appointment: AppointmentRequest // ✅ Using AppointmentRequest
    @ObservedObject var viewModel: TranslationViewModel
    
    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    Image(systemName: "person.crop.circle.fill")
                        .foregroundColor(Color(hex: "787880"))
                        .font(.system(size: 48, weight: .medium))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(appointment.translatorName) // ✅ From appointment
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color(hex: "1A1A1A"))
                        
                        HStack(spacing: 4) {
                            Circle()
                                .fill(appointment.translatorCategory == "متطوع" ? Color(hex: "5CB853") : Color(hex: "EBA0A0"))
                                .frame(width: 6, height: 6)
                            
                            Text(appointment.translatorCategory == "متطوع" ? "Volunteer" : "Paid")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(appointment.translatorCategory == "متطوع" ? Color(hex: "5CB853") : Color(hex: "EBA0A0"))
                        }
                    }
                }
                
                HStack(spacing: 8) {
                    TagView(text: appointment.translatorGender, icon: "person.fill")
                    TagView(text: appointment.translatorAge, icon: "calendar")
                    TagView(text: appointment.translatorLevel, icon: "star.fill")
                }
            }
            .padding(.leading, 16)
            .padding(.trailing, 8)
            
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
                .frame(width: 1, height: 100)
            
            VStack(spacing: 8) {
                VStack(spacing: 2) {
                    HStack(spacing: 4) {
                        Text(appointment.translatorPrice)
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
                
                // ✨ FIXED Cancel button
                Button {
                    if let appointmentId = appointment.id {
                        print("🗑️ Cancel button pressed for appointment: \(appointmentId)")
                        viewModel.cancelAppointment(appointmentId: appointmentId)
                    } else {
                        print("❌ Appointment ID is nil!")
                    }
                } label: {
                    HStack {
                        Image(systemName: "xmark.circle.fill")
                        Text("Cancel")
                    }
                    .foregroundColor(.white)
                    .font(.system(size: 13, weight: .semibold))
                    .frame(width: 110, height: 38)
                    .background(Color.red)
                    .cornerRadius(12)
                }
            }
            .padding(.horizontal, 20)
        }
        .frame(width: 370, height: 150)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.04), radius: 12, x: 0, y: 4)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color(hex: "F5F5F5"), lineWidth: 1)
                )
        )
        .padding(.horizontal, 16)
    }
}

// MARK: - Translator Card
struct TranslatorCard: View {
    let translator: TranslatorData
    @ObservedObject var viewModel: TranslationViewModel
    @State private var showRequistSheet = false
    
    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    Image(systemName: "person.crop.circle.fill")
                        .foregroundColor(Color(hex: "787880"))
                        .font(.system(size: 48, weight: .medium))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(translator.name)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color(hex: "1A1A1A"))
                        
                        HStack(spacing: 4) {
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
                    TagView(text: translator.gender, icon: "person.fill")
                    TagView(text: translator.age, icon: "calendar")
                    TagView(text: translator.level, icon: "star.fill")
                }
            }
            .padding(.leading, 8)
            .padding(.trailing, 8)
            
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
                .frame(width: 1, height: 100)
            
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
                        showRequistSheet = true
                    } label: {
                        HStack {
                            Text("Request")
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
                }
                .sheet(isPresented: $showRequistSheet) {
                    RequistSheet(translator: translator, viewModel: viewModel)
                        .presentationDetents([.medium, .large])
                        .presentationDragIndicator(.hidden)
                }
            }
            .padding(.horizontal, 20)
        }
        .frame(width: 370, height: 150)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.04), radius: 12, x: 0, y: 4)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color(hex: "F5F5F5"), lineWidth: 1)
                )
        )
        .padding(.horizontal, 16)
    }
}

// MARK: - Tag View
struct TagView: View {
    let text: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 9, weight: .medium))
                .foregroundColor(Color(hex: "666666"))
            
            Text(text)
                .font(.system(size: 10, weight: .medium))
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

// MARK: - See All Card
// MARK: - See All Card
struct SeeAllCard: View {
    @ObservedObject var viewModel: TranslationViewModel // ✨ Add this
    
    var body: some View {
        NavigationLink {
            AllTranslatorsView(viewModel: viewModel) // ✨ Pass the viewModel
        } label: {
            VStack(spacing: 20) {
                Image(systemName: "arrow.right")
                    .font(.system(size: 40, weight: .semibold))
                    .foregroundColor(Color(hex: "0D189F"))
                
                Text("See All")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(Color(hex: "1A1A1A"))
            }
            .frame(height: 160)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.04), radius: 12, x: 0, y: 4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color(hex: "F5F5F5"), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 16)
        }
    }
}
// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255)
    }
}

#Preview {
    @State var previewName = ""
    return NavigationView {
        DeafHome(deafName: $previewName)
    }
}
