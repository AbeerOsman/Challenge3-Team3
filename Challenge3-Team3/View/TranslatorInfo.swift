//
//  TranslatorInfo.swift
//  Challenge3-Team3
//
//  Created by Abeer Jeilani Osman  on 21/06/1447 AH.
//

import SwiftUI

import SwiftUI

struct TranslatorInfo: View {
    let translator: TranslatorData
    @ObservedObject var viewModel: TranslationViewModel
    @Environment(\.dismiss) var dismiss

    // حالة الواجهة
    @State private var showSuccessMessage = false
    @State private var isSubmitting = false
    @State private var appear = false

    // ثوابت التخطيط لسهولة التعديل
    private enum Layout {
        static let horizontalPadding: CGFloat = 24
        static let cardCorner: CGFloat = 14
        static let avatarOuter: CGFloat = 96
        static let avatarInner: CGFloat = 56
        static let sectionSpacing: CGFloat = 18
        static let elementSpacing: CGFloat = 14
        static let ctaHeight: CGFloat = 56
        static let headingSize: CGFloat = 20
        static let bodySize: CGFloat = 15
    }

    var body: some View {
        ZStack {
            // خلفية خفيفة لتمييز الشيت
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            VStack(spacing: 12) {
                Spacer()
                // بطاقة المعلومات البيضاء
                card

                Spacer(minLength: 5)

                // زري التأكيد والإلغاء
                ctaArea
            }
            .padding(.top, 98)
            .environment(\.layoutDirection, .rightToLeft)
            .onAppear {
                withAnimation(.spring(response: 0.45, dampingFraction: 0.78)) {
                    appear = true
                }
            }
        }
    }

    // MARK: - Card
    private var card: some View {
        VStack(spacing: Layout.sectionSpacing) {

            // TOP: مزيج أفقي
            HStack(alignment: .center, spacing: Layout.elementSpacing) {
                avatar

                // منتصف عمودي: اسم + وصف قصير
                VStack(alignment: .leading, spacing: 10) {
                    Text(translator.name)
                        .font(.system(size: Layout.headingSize, weight: .bold))
                        .foregroundColor(Color(hex: "0B1B47"))
                        .lineLimit(1)

                    // يمين: سعر واضح رأسياً
                    VStack(alignment: .trailing, spacing: 6) {
                        HStack(spacing: 6) {
                            Text(translator.price)
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(Color(hex: "0D189F"))
                            Image(.ريال)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 22, height: 22)
                                
                            Text("/ الساعة")
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                        }
                        
                    }
                }

                Spacer()
            }
            .padding(.horizontal, Layout.horizontalPadding)
            .padding(.top, 12)

            // --- قسم: معلومات سريعة على شكل قائمة (قابلة للقراءة السريعة)
            VStack(alignment: .leading, spacing: 10) {

                // عناصر القائمة — بعض العناصر على شكل نص وبعضها عناصر قائمة
                VStack(alignment: .leading, spacing: 8) {
                    // عنصر: الجنس و العمر (قائمة موجزة)
                    HStack(spacing: 8) {
                        quickItem(icon: "person.fill", title: translator.gender == "أنثى" ? "أنثى" : "ذكر")
                        quickItem(icon: "calendar", title: translator.age)
                        quickItem(icon: "star.fill", title: translator.level, isLevelItem: true)
                    }

                    // المجالات
                    if shouldShowCareer {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 8) {
                                Image(systemName: "briefcase.fill")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(Color(hex: "0D189F"))
                                
                                Text("المجالات")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(Color(hex: "0D189F"))
                            }
                            
                            // Display careers with icons
                            VStack(alignment: .center, spacing: 6) {
                                ForEach(getCareersList(), id: \.self) { career in
                                    HStack(spacing: 8) {
                                        Spacer()
                                        Image(systemName: getCareerIcon(career))
                                            .font(.system(size: 18, weight: .semibold))
                                            .foregroundColor(Color(hex: "0D189F"))
                                            .frame(width: 25, height: 25)
                                        
                                        Text(career)
                                            .font(.system(size: 15))
                                            .foregroundColor(.black)
                                        
                                        Spacer()
                                    }
                                    
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color(hex: "F5F7FB"))
                            .cornerRadius(8)
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                    }

                }
                .padding(.leading, 6)
            }
            .padding(.horizontal, Layout.horizontalPadding)

            // --- تأكيد ونصي صغير
            VStack(spacing: 8) {
                Text("هل تريد إرسال طلب تواصل؟")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(Color(hex: "0B1B47"))
                    .multilineTextAlignment(.center)

                Text("بمجرد الإرسال ستبدأ محادثة تلقائية بينك وبين المترجم.")
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "4B5563"))
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, Layout.horizontalPadding)
            .padding(.bottom, 6)

            // --- رسائل النجاح/الخطأ
            VStack(spacing: 8) {
                if showSuccessMessage {
                    banner(symbol: "checkmark.circle.fill", text: "تم إرسال طلب التواصل بنجاح!", color: .green)
                }
                if let error = viewModel.errorMessage {
                    banner(symbol: "exclamationmark.triangle.fill", text: error, color: .red)
                }
            }
            .padding(.horizontal, Layout.horizontalPadding)
            .padding(.bottom, 8)

        } // card VStack
        .background(Color.white)
        .cornerRadius(Layout.cardCorner)
        .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 8)
        .padding(.horizontal, 12)
    }

    // MARK: - CTA Area
    private var ctaArea: some View {
        VStack(spacing: 12) {
            Button(action: { dismiss() }) {
                Text("إلغاء")
                    .font(.system(size: 15, weight: .medium))
                    .frame(maxWidth: .infinity)
                    .frame(height: 46)
                    .background(Color(.systemGray6))
                    .foregroundColor(Color.primary)
                    .cornerRadius(12)
            }
            .padding(.horizontal, Layout.horizontalPadding)
            .padding(.bottom, safeAreaBottomPadding())
        }
    }

    // MARK: - Subcomponents

    private var avatar: some View {
        ZStack {
            Circle()
                .fill(Color(hex: "EAF2FF"))
                .frame(width: Layout.avatarOuter, height: Layout.avatarOuter)

            Group {
                if translator.gender == "أنثى" {
                    Image(.femaleIcon)
                        .resizable()
                        .renderingMode(.template)
                        .scaledToFit()
                        .frame(width: Layout.avatarInner, height: Layout.avatarInner)
                        .foregroundColor(Color(hex: "DC7F7F"))
                } else {
                    Image(.maleIcon)
                        .resizable()
                        .renderingMode(.template)
                        .scaledToFit()
                        .frame(width: Layout.avatarInner, height: Layout.avatarInner)
                        .foregroundColor(Color(hex: "092B6F"))
                }
            }
        }
    }

    // عنصر سريع برمز
    private func quickItem(icon: String, title: String, isLevelItem: Bool = false) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .semibold))
                .frame(width: 20, height: 20)
                .foregroundColor(Color(hex: "0D189F"))

            if isLevelItem {
                // Stars view for level
                HStack(spacing: 8) {
                    ForEach(0..<2, id: \.self) { index in
                        Image(systemName: "star.fill")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(
                                index < levelToStars(title)
                                    ? Color(hex: "0D189F")
                                    : Color(hex: "E0E0E0")
                            )
                    }
                }
                .padding(.trailing, 20)
            } else {
                // Original text view
                Text(title)
                    .font(.system(size: Layout.bodySize, weight: .semibold))
                    .foregroundColor(Color(hex: "0B1B47"))
                    .padding(.trailing, 15)
            }
        }
        .padding(10)
        .background(Color(hex: "F5F7FB"))
        .cornerRadius(10)
    }

    // Helper function to convert level text to star count
    private func levelToStars(_ level: String) -> Int {
        let cleanLevel = level.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Arabic - exact matching
        if cleanLevel == "متقدم" {
            return 3
        } else if cleanLevel == "متوسط" {
            return 1
        } else if cleanLevel == "مبتدا" || cleanLevel == "مبتدئ" {
            return 0
        }
        
        // English fallback
        let lowerLevel = cleanLevel.lowercased()
        if lowerLevel.contains("advanced") || lowerLevel.contains("expert") {
            return 3
        } else if lowerLevel.contains("intermediate") || lowerLevel.contains("medium") {
            return 1
        } else if lowerLevel.contains("beginner") || lowerLevel.contains("basic") {
            return 0
        }
        
        // Default
        return 1
    }

    private func banner(symbol: String, text: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: symbol)
                .font(.system(size: 18))
                .foregroundColor(color)
            Text(text)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(color)
            Spacer()
        }
        .padding(12)
        .background(color.opacity(0.08))
        .cornerRadius(12)
    }

    // MARK: - Logic
    private var shouldShowCareer: Bool {
        !translator.career.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && translator.career != "بدون"
    }

    // ✅ Helper Functions for Careers
    private func getCareersList() -> [String] {
        // Split careers by comma and trim whitespace
        translator.career
            .split(separator: "،")
            .map { String($0).trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }
    
    private func getCareerIcon(_ careerName: String) -> String {
        // Map career names to icons
        let careerMap: [String: String] = [
            "القانون": "hammer.circle.fill",
            "الرعاية الصحية": "heart.circle.fill",
            "التعليم": "book.circle.fill",
            "العقار": "house.circle.fill",
            "التجارة": "briefcase.circle.fill"
        ]
        return careerMap[careerName] ?? "briefcase.fill"
    }

    private func submitRequest() {
        isSubmitting = true
        viewModel.errorMessage = nil

        viewModel.requestAppointment(for: translator) { success in
            isSubmitting = false
            if success {
                withAnimation { showSuccessMessage = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 15) {
                    dismiss()
                }
            }
        }
    }

    private func safeAreaBottomPadding() -> CGFloat {
        let window = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
        return (window?.safeAreaInsets.bottom ?? 0) > 0 ? 16 : 12
    }
}

