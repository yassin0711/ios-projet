import SwiftUI
import FirebaseCore
import GoogleSignIn
import GoogleMobileAds

@main
struct MatbakhiApp: App {
    // Services partagés par tous les écrans grâce à .environmentObject (chapitre 3)
    @StateObject private var auth = AuthService()
    @StateObject private var favorites = FavoritesService()
    @StateObject private var planning = PlanningService()
    @StateObject private var shopping = ShoppingService()
    @AppStorage(AppTheme.storageKey) private var theme: AppTheme = .system
    @AppStorage(AppLanguage.storageKey) private var language: AppLanguage = .deviceDefault

    init() {
        // Firebase doit être configuré avant AuthService. Il a besoin du fichier
        // GoogleService-Info.plist (voir README) : sans lui, l'app s'ouvre sans connexion.
        if Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil {
            FirebaseApp.configure()
        }
        // SDK des publicités Google (identifiant de test dans l'onglet Info d'Xcode)
        MobileAds.shared.start(completionHandler: nil)
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(auth)
                .environmentObject(favorites)
                .environmentObject(planning)
                .environmentObject(shopping)
                .preferredColorScheme(theme.colorScheme)
                .environment(\.locale, language.locale)
                .environment(\.layoutDirection, language.layoutDirection)
                // Retour dans l'app après la fenêtre de connexion Google
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
        }
    }
}
