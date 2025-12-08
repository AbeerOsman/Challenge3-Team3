import SwiftUI

struct ChoiceView: View {
    @EnvironmentObject private var appStateManager: AppStateManager
    @EnvironmentObject private var authViewModel: AuthViewModel
    @StateObject private var choiceViewModel = ChoiceViewModel()

    @State private var showDeafNameSheet = false
    @State private var deafName: String = ""
    
    private let corner: CGFloat = 14

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground).ignoresSafeArea()

                VStack(spacing: 24) {
                    Spacer(minLength: 28)

                    VStack(spacing: 8) {
                        Text("يُمْنَاك")
                            .font(.system(size: 35, weight: .semibold))
                            .foregroundColor(Color(hex: "0D189F"))
                            .frame(maxWidth: .infinity, alignment: .center)

                        Text("حيث تُفهم الإشارات ويُسمع صوتها")
                            .font(.system(size: 18))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 28)

                    VStack(spacing: 18) {
                        let cols = [GridItem(.adaptive(minimum: 320), spacing: 16)]
                        LazyVGrid(columns: cols, spacing: 16) {
                            ForEach(choiceViewModel.options) { option in
                                
                                // المستخدم الأصم
                                if option.type == .needInterpreter {
                                    Button(action: {
                                        choiceViewModel.handleTap(on: option)
                                        authViewModel.saveRole(for: option.type)
                                        showDeafNameSheet = true
                                    }) {
                                        CardContent(
                                            title: option.title,
                                            subtitle: "اطلب مترجم إشارة مباشر",
                                            systemName: "ear.fill",
                                            accent: .indigo
                                        )
                                    }
                                    .buttonStyle(CardButtonStyle())
                                    .accessibilityLabel("\(option.title). اطلب مترجم مباشر.")
                                
                                // المترجم
                                } else {
                                    NavigationLink(
                                        destination:
                                            InterpreterTabView()
                                                .environmentObject(authViewModel)
                                                .environmentObject(appStateManager)
                                    ) {
                                        CardContent(
                                            title: option.title,
                                            subtitle: "انضم كمترجم لغة الإشارة",
                                            systemName: "person.2.fill",
                                            accent: .teal
                                        )
                                    }
                                    .simultaneousGesture(TapGesture().onEnded {
                                        choiceViewModel.handleTap(on: option)
                                        authViewModel.saveRole(for: option.type)
                                        appStateManager.setUserRole("interpreter")
                                    })
                                    .buttonStyle(PlainButtonStyle())
                                    .accessibilityLabel("\(option.title). انضم كمترجم.")
                                }
                            }
                        }
                        .animation(.easeInOut, value: choiceViewModel.options.count)
                    }
                    .padding(18)
                    .background(
                        RoundedRectangle(cornerRadius: corner)
                            .fill(Color(.systemBackground))
                            .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 8)
                    )
                    .padding(.horizontal, 20)

                    Spacer()
                }
            }
            .navigationBarBackButtonHidden(false)
            .sheet(isPresented: $showDeafNameSheet) {
                DeafNameSheet(
                    authViewModel: authViewModel,
                    navigateToDeafHome: .constant(false),
                    isPresented: $showDeafNameSheet,
                    deafName: $deafName,
                    onSave: {
                        appStateManager.setUserRole("requester", deafName: deafName)
                    }
                )
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.hidden)
            }
        }
        .environment(\.layoutDirection, .rightToLeft) // جعل الواجهة من اليمين لليسار
    }
}

// MARK: - Card Content
struct CardContent: View {
    let title: String
    let subtitle: String
    let systemName: String
    let accent: Color

    var body: some View {
        HStack(spacing: 14) {
            
            RoundedRectangle(cornerRadius: 10)
                .fill(accent.opacity(0.15))
                .frame(width: 72, height: 72)
                .overlay(
                    Image(systemName: systemName)
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(accent)
                )

            VStack(alignment: .center, spacing: 6) {
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .center)

                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }

            Spacer()

            // سهم التنقل يعكس اتجاهه في RTL
            Image(systemName: "chevron.left")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color(.tertiaryLabel))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
}

// MARK: - Button Style
struct CardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.987 : 1.0)
            .opacity(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

// MARK: - Preview
struct ChoiceView_Previews: PreviewProvider {
    static var previews: some View {
        ChoiceView()
            .environmentObject(AppStateManager())
            .environmentObject(AuthViewModel())
            .environment(\.layoutDirection, .rightToLeft)
    }
}
