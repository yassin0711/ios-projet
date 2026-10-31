import SwiftUI

/// Aiguillage principal : écran de lancement → présentation (1re fois) → app.
/// La connexion Firebase (écrans Connexion / Inscription) viendra s'insérer ici.
struct RootView: View {
    static let onboardingKey = "onboarding.done"

    @AppStorage(RootView.onboardingKey) private var onboardingDone = false
    @AppStorage(AppLanguage.storageKey) private var language: AppLanguage = .deviceDefault
    @State private var showSplash = true

    var body: some View {
        ZStack {
            if showSplash {
                SplashView {
                    withAnimation(.easeInOut(duration: 0.4)) { showSplash = false }
                }
                .transition(.opacity)
            } else if !onboardingDone {
                OnboardingView {
                    withAnimation(.easeInOut(duration: 0.4)) { onboardingDone = true }
                }
                .transition(.opacity)
            } else {
                MainTabView()
                    // Changer de langue reconstruit l'interface pour retraduire tous les textes
                    .id(language)
                    .transition(.opacity)
            }
        }
    }
}
