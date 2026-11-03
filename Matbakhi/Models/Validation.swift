import Foundation

/// Règles des formulaires : chaque fonction renvoie la clé du message d'erreur, ou nil si c'est valide
enum Validation {
    static func name(_ name: String) -> String? {
        name.trimmingCharacters(in: .whitespaces).count >= 2 ? nil : "validation.name"
    }

    static func email(_ email: String) -> String? {
        let parts = email.split(separator: "@")
        return parts.count == 2 && parts[1].contains(".") ? nil : "validation.email"
    }

    static func password(_ password: String) -> String? {
        password.count >= 6 ? nil : "validation.password"
    }

    static func confirmation(_ password: String, _ confirmation: String) -> String? {
        password == confirmation ? nil : "validation.confirm"
    }
}
