import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var auth: AuthService

    @State private var email = ""
    @State private var password = ""
    @State private var showErrors = false   // les erreurs s'affichent après le premier essai
    @State private var isLoading = false
    @State private var errorKey: String?    // erreur renvoyée par Firebase

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    Image(systemName: "fork.knife.circle.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(.tint)

                    Text("auth.login.title".localized)
                        .font(.largeTitle.bold())

                    FormField(titleKey: "auth.email", text: $email,
                              errorKey: showErrors ? Validation.email(email) : nil)

                    FormField(titleKey: "auth.password", text: $password, isSecure: true,
                              errorKey: showErrors ? Validation.password(password) : nil)

                    NavigationLink("auth.forgot.link".localized) { ForgotPasswordView() }
                        .font(.footnote)
                        .frame(maxWidth: .infinity, alignment: .trailing)

                    if let errorKey {
                        Text(errorKey.localized)
                            .foregroundStyle(.red)
                    }

                    Button {
                        Task { await signIn() }
                    } label: {
                        Text("auth.login.button".localized)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)

                    Button {
                        Task { await signInWithGoogle() }
                    } label: {
                        Label("auth.google".localized, systemImage: "g.circle.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)

                    if isLoading {
                        ProgressView()
                    }

                    NavigationLink("auth.signup.link".localized) { SignUpView() }
                }
                .padding()
                .disabled(isLoading)
            }
        }
    }

    private func signIn() async {
        showErrors = true
        errorKey = nil
        guard Validation.email(email) == nil, Validation.password(password) == nil else { return }

        isLoading = true
        do {
            try await auth.signIn(email: email, password: password)
        } catch {
            errorKey = AuthService.messageKey(for: error)
        }
        isLoading = false
    }

    private func signInWithGoogle() async {
        errorKey = nil
        isLoading = true
        do {
            try await auth.signInWithGoogle()
        } catch {
            errorKey = AuthService.messageKey(for: error)
        }
        isLoading = false
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthService())
}
