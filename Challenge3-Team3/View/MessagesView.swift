import SwiftUI

// MARK: - MessagesView
// شاشة الرسائل العامة للمستخدم.
// - حالياً تعرض نصاً تمهيدياً (Placeholder) عند عدم وجود رسائل.
// - مغلّفة داخل NavigationView مع عنوان شريط تنقل.
struct MessagesView: View {
    var body: some View {
        NavigationView {
            VStack {
                // محتوى الرسائل المبدئي (Placeholder)
                Text("لا توجد رسائل حالياً")
                    .foregroundColor(.secondary)
                    .padding()

                Spacer()
            }
            .navigationTitle("الرسائل")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    MessagesView()
}
