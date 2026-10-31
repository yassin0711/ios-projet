import SwiftUI

@main
struct MatbakhiApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @AppStorage(AppTheme.storageKey) private var theme: AppTheme = .system
    @AppStorage(AppLanguage.storageKey) private var language: AppLanguage = .deviceDefault

    init() {
        // Captures d'écran automatiques du CI (argument -skipOnboarding YES) : on saute la présentation
        if UserDefaults.standard.bool(forKey: "skipOnboarding") {
            UserDefaults.standard.set(true, forKey: RootView.onboardingKey)
        }
        LanguageManager.applyLayoutDirection(AppLanguage.current)
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.locale, language.locale)
                .environment(\.layoutDirection, language.layoutDirection)
                .onAppear { ThemeManager.apply(theme) }
                .onChange(of: theme) { ThemeManager.apply(theme, animated: true) }
                .onChange(of: language) { LanguageManager.applyLayoutDirection(language) }
        }
    }
}
