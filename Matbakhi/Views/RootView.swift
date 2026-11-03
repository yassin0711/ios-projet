import SwiftUI

/// Aiguillage principal : écran de lancement → présentation (1re fois) → connexion → app
struct RootView: View {
    @EnvironmentObject private var auth: AuthService
    @AppStorage("onboarding.done") private var onboardingDone = false
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
            } else if auth.isFirebaseConfigured && auth.user == nil {
                // Personne n'est connecté
                LoginView()
                    .transition(.opacity)
            } else {
                MainTabView()
                    // Changer de langue reconstruit l'interface pour retraduire tous les textes
                    .id(language)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut, value: auth.user?.uid)
    }
}
