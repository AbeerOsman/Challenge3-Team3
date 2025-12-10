//import SwiftUI
//
//struct RequistSheet: View {
//    let translator: TranslatorData
//    @ObservedObject var viewModel: TranslationViewModel
//    @Environment(\.dismiss) var dismiss
//    @State private var showSuccessMessage = false
//    @State private var isSubmitting = false
//    
//    var body: some View {
//        VStack(spacing: 20) {
//            HStack {
//                Color.clear.frame(width: 20, height: 20)
//                Spacer()
//                Button {
//                    dismiss()
//                } label: {
//                    Image(systemName: "xmark")
//                        .font(.system(size: 20))
//                        .foregroundColor(.gray)
//                }
//            }
//            .padding(.horizontal, 24)
//            .padding(.top, 20)
//            
//            
//            VStack(spacing: 16) {
//                // Career Section
//                if !translator.career.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
//                   translator.career != "بدون" {
//                    VStack(alignment: .leading, spacing: 8) {
//                        // Section header with icon
//                        HStack(spacing: 8) {
//                            Image(systemName: "briefcase.fill")
//                            Text("المجالات")
//                        }
//                        
//                        // Career display
//                        Text(translator.career)
//                            .padding(.horizontal, 12)
//                            .padding(.vertical, 8)
//                            .background(Color(hex: "F5F7FB"))
//                            .cornerRadius(8)
//                    }
//                }
//                if translator.gender == "أنثى" {
//                    Image(.femaleIcon)
//                        .resizable()
//                        .renderingMode(.template)
//                        .scaledToFit()
//                        .frame(width: 70, height: 70)
//                        .foregroundColor(Color(hex: "DC7F7F"))
//                } else {
//                    Image(.maleIcon)
//                        .resizable()
//                        .renderingMode(.template)
//                        .scaledToFit()
//                        .frame(width: 70, height: 70)
//                        .foregroundColor(Color(hex: "092B6F"))
//                }
//                
//                Text(translator.name)
//                    .font(.system(size: 24, weight: .bold))
//                    .foregroundColor(Color(hex: "1A1A1A"))
//                
//                HStack(spacing: 12) {
//                    TagView(text: translator.gender == "أنثى" ? "أنثى" : "ذكر", icon: "person.fill")
//                    TagView(text: translator.age, icon: "calendar")
//                    TagView(text: translator.level, icon: "star.fill")
//                }
//                
//                HStack(spacing: 8) {
//                    
//                    Text(translator.price)
//                        .font(.system(size: 32, weight: .bold))
//                        .foregroundColor(Color(hex: "0D189F"))
//                    
//                    Text("/ الساعة")
//                        .font(.system(size: 18))
//                        .foregroundColor(.gray)
//                    
//                    Image(.ريال)
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 26, height: 26)
//                }
//                
//            }
//            .padding(.vertical, 20)
//            
//            VStack(spacing: 12) {
//
//                Text("هل تريد بالتأكيد إرسال طلب تواصل إلى المترجم؟")
//                    .font(.system(size: 20, weight: .bold))
//                    .multilineTextAlignment(.center)
//                    .foregroundColor(.black)
//                    .lineLimit(nil)
//                    .fixedSize(horizontal: false, vertical: true)
//
//                Text("بمجرد إرسال طلبك، ستفتح محادثة تلقائية بينك ومترجم.")
//                    .font(.subheadline)
//                    .multilineTextAlignment(.center)
//                    .foregroundColor(.black)
//                    .lineLimit(nil)
//                    .fixedSize(horizontal: false, vertical: true)
//
//            }
//            .padding(.horizontal, 36)
//            .padding(.top, 6)
//            
//            Spacer()
//            
//            if showSuccessMessage {
//                HStack(spacing: 12) {
//                    Image(systemName: "checkmark.circle.fill")
//                        .foregroundColor(.green)
//                        .font(.system(size: 24))
//                    
//                    Text("تم إرسال الطلب بنجاح!")
//                        .font(.system(size: 16, weight: .semibold))
//                        .foregroundColor(.green)
//                }
//                .padding()
//                .background(Color.green.opacity(0.1))
//                .cornerRadius(12)
//            }
//            
//            if let error = viewModel.errorMessage {
//                HStack(spacing: 12) {
//                    Image(systemName: "exclamationmark.triangle.fill")
//                        .foregroundColor(.red)
//                        .font(.system(size: 24))
//                    
//                    Text(error)
//                        .font(.system(size: 14, weight: .medium))
//                        .foregroundColor(.red)
//                }
//                .padding()
//                .background(Color.red.opacity(0.1))
//                .cornerRadius(12)
//            }
//            
//            Button {
//                submitRequest()
//            } label: {
//                HStack {
//                    if isSubmitting {
//                        ProgressView()
//                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
//                    } else {
//                        Text("تأكيد طلب التواصل")
//                            .font(.system(size: 18, weight: .semibold))
//                    }
//                }
//                .foregroundColor(.white)
//                .frame(maxWidth: .infinity)
//                .frame(height: 56)
//                .background(
//                    LinearGradient(
//                        colors: [Color(hex: "0D189F"), Color(hex: "0A1280")],
//                        startPoint: .topLeading,
//                        endPoint: .bottomTrailing
//                    )
//                )
//                .cornerRadius(16)
//            }
//            .disabled(isSubmitting)
//            .padding(.horizontal, 24)
//            .padding(.bottom, 32)
//        }
//        .padding(.bottom, 16)
//        .frame(maxWidth: .infinity)
//        .background(
//            Color(hex: "DDE8FD")
//                .ignoresSafeArea(edges: .bottom)
//        )
//        .environment(\.layoutDirection, .rightToLeft)
//    }
//    
//    private func submitRequest() {
//        isSubmitting = true
//        viewModel.errorMessage = nil
//        
//        viewModel.requestAppointment(for: translator) { success in
//            isSubmitting = false
//            
//            if success {
//                withAnimation {
//                    showSuccessMessage = true
//                }
//                
//                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
//                    dismiss()
//                }
//            }
//        }
//    }
//}


import SwiftUI

// RequistSheetV5.swift
// تصميم واضح كملف شخصي — سهل القراءة للمستخدم الصم
// مزيج بين عناصر قائمة (قابلة للقراءة بسرعة) ونصوص وصفية
// المحافظة على نفس الـlogic: شروط عرض career، استدعاء viewModel.requestAppointment(for:), رسائل النجاح/الخطأ، وإغلاق بعدها 5 ثواني.

struct RequistSheet: View {
    let translator: TranslatorData
    @ObservedObject var viewModel: TranslationViewModel
    @Environment(\ .dismiss) var dismiss

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
                // Header صغير مع مقبض سحب وزر إغلاق
                header

                // بطاقة المعلومات البيضاء
                card

                Spacer(minLength: 10)

                // زري التأكيد والإلغاء
                ctaArea
            }
            .padding(.top, 6)
            .environment(\.layoutDirection, .rightToLeft)
            .onAppear {
                withAnimation(.spring(response: 0.45, dampingFraction: 0.78)) {
                    appear = true
                }
            }
        }
    }

    // MARK: - Header
    private var header: some View {
        HStack {
            Spacer()
            Capsule()
                .fill(Color.gray.opacity(0.35))
                .frame(width: 80, height: 6)
                .padding(.vertical, 10)
            Spacer()
            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color.primary)
                    .frame(width: 36, height: 36)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 4)
            }
            .padding(.trailing, Layout.horizontalPadding / 2)
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

                    // وصف سريع قابل للقراءة (نص رئيسي)
                    Text(shortDescription)
                        .font(.system(size: Layout.bodySize))
                        .foregroundColor(Color(hex: "374151"))
                        .lineLimit(3)
                }

                Spacer()

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
                    }
                    Text("/ الساعة")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, Layout.horizontalPadding)
            .padding(.top, 12)

            // --- قسم: معلومات سريعة على شكل قائمة (قابلة للقراءة السريعة)
            VStack(alignment: .leading, spacing: 10) {
//                // عنوان القائمة
//                HStack(alignment: .center, spacing: 8) {
//                    Image(systemName: "info.circle.fill")
//                        .font(.system(size: 16))
//                        .foregroundColor(Color(hex: "0D189F"))
//                    Text("معلومات سريعة")
//                        .font(.system(size: 16, weight: .semibold))
//                        .foregroundColor(Color(hex: "0B1B47"))
//                }

                // عناصر القائمة — بعض العناصر على شكل نص وبعضها عناصر قائمة
                VStack(alignment: .leading, spacing: 8) {
                    // عنصر: الجنس و العمر (قائمة موجزة)
                    HStack(spacing: 12) {
                        quickItem(icon: "person.fill", title: translator.gender == "أنثى" ? "أنثى" : "ذكر")
                        quickItem(icon: "calendar", title: translator.age)
                        quickItem(icon: "star.fill", title: translator.level)
                    }

                    // عنصر كنص: المجالات (وصف أطول يُعرض كفقرة صغيرة)
                    if shouldShowCareer {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("المجالات")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(hex: "0B1B47"))

                            // نص الوصف للمجالات — نعرضه كفقرة منفصلة لسهولة القراءة
                            Text(translator.career)
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex: "374151"))
                                .padding(10)
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                        }
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
                    banner(symbol: "checkmark.circle.fill", text: "تم إرسال الطلب بنجاح!", color: .green)
                }
                if let error = viewModel.errorMessage {
                    banner(symbol: "exclamationmark.triangle.fill", text: error, color: .red)
                }
            }
            .padding(.horizontal, Layout.horizontalPadding)
            .padding(.bottom, 8)

        } // card VStack
        .background(Color.white) // الكارد أبيض كما طلبت
        .cornerRadius(Layout.cardCorner)
        .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 8)
        .padding(.horizontal, 12)
    }

    // MARK: - CTA Area
    private var ctaArea: some View {
        VStack(spacing: 12) {
            Button(action: { submitRequest() }) {
                HStack {
                    if isSubmitting {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("تأكيد طلب التواصل")
                            .font(.system(size: 17, weight: .semibold))
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: Layout.ctaHeight)
                .background(LinearGradient(gradient: Gradient(colors: [Color(hex: "0D189F"), Color(hex: "0A1280")]), startPoint: .leading, endPoint: .trailing))
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(isSubmitting)
            .padding(.horizontal, Layout.horizontalPadding)

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
                if translator.gender == "Female" {
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
    private func quickItem(icon: String, title: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .frame(width: 28, height: 28)
                .foregroundColor(Color(hex: "0D189F"))

            Text(title)
                .font(.system(size: Layout.bodySize, weight: .semibold))
                .foregroundColor(Color(hex: "0B1B47"))
        }
        .padding(10)
        .background(Color(.systemGray6))
        .cornerRadius(10)
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

    // وصف قصير تلقائي — نجمع بعض الحقول لفقرة موجزة سهلة القراءة
    private var shortDescription: String {
        var parts: [String] = []
        if !translator.career.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && translator.career != "بدون" {
            parts.append(translator.career)
        }
        parts.append("مستوى: \(translator.level)")
        return parts.joined(separator: " • ")
    }

    // MARK: - Logic
    private var shouldShowCareer: Bool {
        !translator.career.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && translator.career != "بدون"
    }

    private func submitRequest() {
        isSubmitting = true
        viewModel.errorMessage = nil

        viewModel.requestAppointment(for: translator) { success in
            isSubmitting = false
            if success {
                withAnimation { showSuccessMessage = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
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



