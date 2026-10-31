import SwiftUI

@main
struct MatbakhiApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @AppStorage(AppTheme.storageKey) private var theme: AppTheme = .system
    @AppStorage(AppLanguage.storageKey) private var language: AppLanguage = .deviceDefault

    init() {
        // Utilisé par GitHub Actions pour les captures d'écran : on saute la présentation
        if UserDefaults.standard.bool(forKey: "skipOnboarding") {
            UserDefaults.standard.set(true, forKey: RootView.onboardingKey)
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .preferredColorScheme(theme.colorScheme)
                .environment(\.locale, language.locale)
                .environment(\.layoutDirection, language.layoutDirection)
        }
    }
}
