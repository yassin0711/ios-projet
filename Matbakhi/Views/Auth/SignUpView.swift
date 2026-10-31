import SwiftUI

struct SignUpView: View {
    @EnvironmentObject private var auth: AuthService

    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmation = ""
    @State private var showErrors = false
    @State private var isLoading = false
    @State private var errorKey: String?

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                FormField(titleKey: "auth.name", text: $name,
                          errorKey: showErrors ? Validation.name(name) : nil)

                FormField(titleKey: "auth.email", text: $email,
                          errorKey: showErrors ? Validation.email(email) : nil)

                FormField(titleKey: "auth.password", text: $password, isSecure: true,
                          errorKey: showErrors ? Validation.password(password) : nil)

                FormField(titleKey: "auth.confirm", text: $confirmation, isSecure: true,
                          errorKey: showErrors ? Validation.confirmation(password, confirmation) : nil)

                if let errorKey {
                    Text(errorKey.localized)
                        .foregroundStyle(.red)
                }

                Button {
                    Task { await signUp() }
                } label: {
                    Text("auth.signup.button".localized)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

                if isLoading {
                    ProgressView()
                }
            }
            .padding()
            .disabled(isLoading)
        }
        .navigationTitle("auth.signup.title".localized)
    }

    private func signUp() async {
        showErrors = true
        errorKey = nil
        guard Validation.name(name) == nil,
              Validation.email(email) == nil,
              Validation.password(password) == nil,
              Validation.confirmation(password, confirmation) == nil
        else { return }

        isLoading = true
        do {
            // En cas de succès, Firebase connecte l'utilisateur et RootView affiche l'app
            try await auth.signUp(name: name, email: email, password: password)
        } catch {
            errorKey = AuthService.messageKey(for: error)
        }
        isLoading = false
    }
}

#Preview {
    NavigationStack {
        SignUpView()
            .environmentObject(AuthService())
    }
}
