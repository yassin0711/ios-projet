import SwiftUI

/// Thème choisi dans les Réglages
enum AppTheme: String, CaseIterable, Identifiable {
    case system, light, dark

    static let storageKey = "app.theme"

    var id: String { rawValue }
    var titleKey: String { "theme.\(rawValue)" }

    var icon: String {
        switch self {
        case .system: return "circle.lefthalf.filled"
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        }
    }

    /// nil = suivre le réglage du téléphone
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

/// Langue choisie dans les Réglages
enum AppLanguage: String, CaseIterable, Identifiable {
    case french = "fr"
    case english = "en"
    case arabic = "ar"

    static let storageKey = "app.language"

    var id: String { rawValue }

    /// Chaque langue est affichée dans sa propre écriture
    var displayName: String {
        switch self {
        case .french: return "Français"
        case .english: return "English"
        case .arabic: return "العربية"
        }
    }

    var locale: Locale { Locale(identifier: rawValue) }

    /// L'arabe se lit de droite à gauche : toute la mise en page est inversée
    var layoutDirection: LayoutDirection { self == .arabic ? .rightToLeft : .leftToRight }

    /// Langue du téléphone si elle est gérée, sinon le français
    static var deviceDefault: AppLanguage {
        let code = Locale.preferredLanguages.first?.prefix(2) ?? "fr"
        return AppLanguage(rawValue: String(code)) ?? .french
    }

    /// Langue enregistrée par les Réglages (même clé que @AppStorage)
    static var current: AppLanguage {
        AppLanguage(rawValue: UserDefaults.standard.string(forKey: storageKey) ?? "") ?? deviceDefault
    }
}
