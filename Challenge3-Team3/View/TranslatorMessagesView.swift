import SwiftUI

// MARK: - TranslatorMessagesView
// شاشة بسيطة لعرض رسائل المترجم.
// - حالياً تعرض رسالة فارغة افتراضية.
// - موضوعة داخل NavigationView مع عنوان في الـ Navigation Bar.
struct TranslatorMessagesView: View {
    var body: some View {
        NavigationView {
            VStack {
                // محتوى الرسائل المبدئي (Placeholder)
                Text("لا توجد رسائل حالياً")
                    .foregroundColor(.secondary)
                    .padding()

                Spacer()
            }
            .navigationTitle("رسائلي كمترجم")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    TranslatorMessagesView()
}
