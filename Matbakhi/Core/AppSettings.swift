import SwiftUI
import UIKit

// MARK: - Thème clair / sombre

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

    var interfaceStyle: UIUserInterfaceStyle {
        switch self {
        case .system: return .unspecified
        case .light: return .light
        case .dark: return .dark
        }
    }
}

enum ThemeManager {
    /// On applique le thème sur la fenêtre UIKit : cela couvre aussi les sheets et les alertes,
    /// et le retour au thème « Système » fonctionne sans relancer l'app.
    @MainActor
    static func apply(_ theme: AppTheme, animated: Bool = false) {
        let windows = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }

        for window in windows {
            if animated {
                UIView.transition(with: window, duration: 0.35, options: .transitionCrossDissolve) {
                    window.overrideUserInterfaceStyle = theme.interfaceStyle
                }
            } else {
                window.overrideUserInterfaceStyle = theme.interfaceStyle
            }
        }
    }
}

// MARK: - Langue (français, anglais, arabe)

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
    var isRightToLeft: Bool { self == .arabic }
    var layoutDirection: LayoutDirection { isRightToLeft ? .rightToLeft : .leftToRight }

    /// Langue du téléphone si elle est gérée, sinon le français
    static var deviceDefault: AppLanguage {
        let code = Locale.preferredLanguages.first?.prefix(2) ?? "fr"
        return AppLanguage(rawValue: String(code)) ?? .french
    }

    /// Langue choisie dans les Réglages (même clé que @AppStorage)
    static var current: AppLanguage {
        let stored = UserDefaults.standard.string(forKey: storageKey) ?? ""
        return AppLanguage(rawValue: stored) ?? deviceDefault
    }
}

enum LanguageManager {
    /// Inverse les composants UIKit (barres de navigation, onglets) pour l'arabe
    @MainActor
    static func applyLayoutDirection(_ language: AppLanguage) {
        UIView.appearance().semanticContentAttribute = language.isRightToLeft
            ? .forceRightToLeft
            : .forceLeftToRight
    }
}
