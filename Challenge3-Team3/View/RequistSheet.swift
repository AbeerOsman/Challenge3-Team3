import SwiftUI

struct RequistSheet: View {
    let translator: TranslatorData
    @ObservedObject var viewModel: TranslationViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showSuccessMessage = false
    @State private var isSubmitting = false
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 20))
                        .foregroundColor(.gray)
                }
                Spacer()
                Color.clear.frame(width: 20, height: 20)
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            
            
            VStack(spacing: 16) {
                if translator.gender == "Female" {
                    Image(.femaleIcon)
                        .resizable()
                        .renderingMode(.template)
                        .scaledToFit()
                        .frame(width: 70, height: 70)
                        .foregroundColor(Color(hex: "DC7F7F"))
                } else {
                    Image(.maleIcon)
                        .resizable()
                        .renderingMode(.template)
                        .scaledToFit()
                        .frame(width: 70, height: 70)
                        .foregroundColor(Color(hex: "092B6F"))
                }
                
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
                    
                    Text("/ Hour")
                        .font(.system(size: 18))
                        .foregroundColor(.gray)
                }
            }
            .padding(.vertical, 20)
            
            VStack(spacing: 12) {

                Text("Are you sure you want to send the request to the interpreter?")
                    .font(.system(size: 20, weight: .bold))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.black)

                Text("Once your request is sent, the interpreter will respond to you.")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.black)

            }
            .padding(.horizontal, 36)   // clean consistent padding
            .padding(.top, 6)
            
            Spacer()
            
            if showSuccessMessage {
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.system(size: 24))
                    
                    Text("Request sent successfully!")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.green)
                }
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(12)
            }
            
            if let error = viewModel.errorMessage {
                HStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                        .font(.system(size: 24))
                    
                    Text(error)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.red)
                }
                .padding()
                .background(Color.red.opacity(0.1))
                .cornerRadius(12)
            }
            
            Button {
                submitRequest()
            } label: {
                HStack {
                    if isSubmitting {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Confirm Request")
                            .font(.system(size: 18, weight: .semibold))
                    }
                }
                .foregroundColor(.white)
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
            }
            .disabled(isSubmitting)
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .padding(.bottom, 16)
        .frame(maxWidth: .infinity)
        .background(
            Color(hex: "DDE8FD")
                .ignoresSafeArea(edges: .bottom)
        )
        .environment(\.layoutDirection, .leftToRight)
    }
    
    private func submitRequest() {
        isSubmitting = true
        viewModel.errorMessage = nil
        
        viewModel.requestAppointment(for: translator) { success in
            isSubmitting = false
            
            if success {
                withAnimation {
                    showSuccessMessage = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    dismiss()
                }
            }
        }
    }
}
