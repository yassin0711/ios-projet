import SwiftUI
import FirebaseCore
import GoogleSignIn

@main
struct MatbakhiApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var auth = AuthService()
    @StateObject private var favorites = FavoritesService()
    @AppStorage(AppTheme.storageKey) private var theme: AppTheme = .system
    @AppStorage(AppLanguage.storageKey) private var language: AppLanguage = .deviceDefault

    init() {
        // Firebase doit être configuré avant AuthService. Il a besoin du fichier
        // GoogleService-Info.plist (voir README) : sans lui, l'app s'ouvre sans connexion.
        if Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil {
            FirebaseApp.configure()
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(auth)
                .environmentObject(favorites)
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
