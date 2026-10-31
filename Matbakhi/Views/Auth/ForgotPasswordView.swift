import SwiftUI

struct ForgotPasswordView: View {
    @EnvironmentObject private var auth: AuthService

    @State private var email = ""
    @State private var showErrors = false
    @State private var isLoading = false
    @State private var errorKey: String?
    @State private var emailSent = false

    var body: some View {
        VStack(spacing: 16) {
            Text("auth.forgot.message".localized)
                .foregroundStyle(.secondary)

            FormField(titleKey: "auth.email", text: $email,
                      errorKey: showErrors ? Validation.email(email) : nil)

            if emailSent {
                Label("auth.forgot.sent".localized, systemImage: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            }

            if let errorKey {
                Text(errorKey.localized)
                    .foregroundStyle(.red)
            }

            Button {
                Task { await sendLink() }
            } label: {
                Text("auth.forgot.button".localized)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(isLoading)

            Spacer()
        }
        .padding()
        .navigationTitle("auth.forgot.title".localized)
    }

    private func sendLink() async {
        showErrors = true
        errorKey = nil
        guard Validation.email(email) == nil else { return }

        isLoading = true
        do {
            try await auth.resetPassword(email: email)
            emailSent = true
        } catch {
            errorKey = AuthService.messageKey(for: error)
        }
        isLoading = false
    }
}

#Preview {
    NavigationStack {
        ForgotPasswordView()
            .environmentObject(AuthService())
    }
}
