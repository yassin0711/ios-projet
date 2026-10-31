import SwiftUI

/// Champ de formulaire avec son message d'erreur en dessous (bordure rouge si erreur)
struct FormField: View {
    let titleKey: String
    @Binding var text: String
    var isSecure = false
    var errorKey: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Group {
                if isSecure {
                    SecureField(titleKey.localized, text: $text)
                } else {
                    TextField(titleKey.localized, text: $text)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
            }
            .padding(12)
            .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(errorKey == nil ? Color.clear : Color.red)
            )

            if let errorKey {
                Text(errorKey.localized)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
    }
}

#Preview {
    FormField(titleKey: "auth.email", text: .constant("ali"), errorKey: "validation.email")
        .padding()
}
