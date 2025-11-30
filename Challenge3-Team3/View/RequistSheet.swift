import SwiftUI

struct RequistSheet: View {
    let translator: TranslatorData
    @ObservedObject var viewModel: TranslationViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showSuccessMessage = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 20))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Text("طلب موعد")
                    .font(.system(size: 22, weight: .bold))
                
                Spacer()
                
                // Empty space for balance
                Color.clear.frame(width: 20, height: 20)
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            
            Divider()
            
            // Translator Info
            VStack(spacing: 16) {
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(Color(hex: "787880"))
                
                Text(translator.name)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(hex: "1A1A1A"))
                
                HStack(spacing: 12) {
                    TagView(text: translator.gender, icon: "person.fill")
                    TagView(text: translator.age, icon: "calendar")
                    TagView(text: translator.level, icon: "star.fill")
                }
                
                HStack(spacing: 8) {
                    Text(translator.price)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(Color(hex: "0D189F"))
                    
                    Image(.ريال)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 26, height: 26)
                    
                    Text("/ ساعة")
                        .font(.system(size: 18))
                        .foregroundColor(.gray)
                }
            }
            .padding(.vertical, 20)
            
            
            VStack(spacing: 12) {

                         Text("هل أنت متأكد من إرسال الطلب للمترجم ؟")
                             .font(.system(size: 20, weight: .bold))
                             .multilineTextAlignment(.center)
                             .foregroundColor(.black)

                         Text("عند إرسال الطلب، سيتم الرد عليك من خلال المترجم")
                             .font(.subheadline)
                             .multilineTextAlignment(.center)
                             .foregroundColor(.black)
                             .padding(.horizontal, 28)
                     }
                     .padding(.top, 6)
            
            Spacer()
            
            // Success Message
            if showSuccessMessage {
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.system(size: 24))
                    
                    Text("تم إرسال طلبك بنجاح للمترجم!")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.green)
                }
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(12)
                .transition(.scale.combined(with: .opacity))
            }
            
            // Confirm Button
            Button {
                withAnimation {
                    viewModel.requestAppointment(for: translator)
                    showSuccessMessage = true
                }
                
                // Dismiss after 1.5 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    dismiss()
                }
            } label: {
                Text("تأكيد الطلب")
                    .foregroundColor(.white)
                    .font(.system(size: 18, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "0D189F"), Color(hex: "0A1280")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(16)
                    .shadow(color: Color(hex: "0D189F").opacity(0.3), radius: 12, x: 0, y: 6)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .padding(.bottom, 16)
                .frame(maxWidth: .infinity) // مهم عشان يتوسع بعرض الشيت بشكل صحيح
                .background(
                    Color(hex: "DDE8FD") // خلفية الشيت
                        .ignoresSafeArea(edges: .bottom) // نخليها تمتد للأسفل داخل الشيت فقط
                )
                .environment(\.layoutDirection, .rightToLeft)
    }
}
