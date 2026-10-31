import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn

/// Connexion avec Firebase Authentication (e-mail / mot de passe et Google).
/// Partagé avec toutes les vues grâce à @EnvironmentObject (chapitre 3).
final class AuthService: ObservableObject {
    /// Utilisateur connecté (nil = personne n'est connecté)
    @Published private(set) var user: User?

    /// false si GoogleService-Info.plist est absent : l'app s'ouvre alors sans connexion
    let isFirebaseConfigured = FirebaseApp.app() != nil

    private var listener: NSObjectProtocol?

    init() {
        guard isFirebaseConfigured else { return }
        // Firebase nous prévient à chaque connexion et déconnexion
        listener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.user = user
        }
    }

    func signIn(email: String, password: String) async throws {
        try await Auth.auth().signIn(withEmail: email, password: password)
    }

    func signUp(name: String, email: String, password: String) async throws {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        let change = result.user.createProfileChangeRequest()
        change.displayName = name
        try await change.commitChanges()
        try await saveProfile(of: result.user, name: name)
    }

    func resetPassword(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }

    @MainActor
    func signInWithGoogle() async throws {
        guard let clientID = FirebaseApp.app()?.options.clientID,
              let rootViewController = UIApplication.shared.connectedScenes
                .compactMap({ ($0 as? UIWindowScene)?.keyWindow?.rootViewController })
                .first
        else { return }

        // 1. Fenêtre de connexion Google
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
        let result: GIDSignInResult
        do {
            result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
        } catch GIDSignInError.canceled {
            return   // l'utilisateur a fermé la fenêtre : ce n'est pas une erreur
        }

        // 2. Connexion à Firebase avec le compte Google
        guard let idToken = result.user.idToken?.tokenString else { return }
        let credential = GoogleAuthProvider.credential(
            withIDToken: idToken,
            accessToken: result.user.accessToken.tokenString
        )
        let authResult = try await Auth.auth().signIn(with: credential)
        try await saveProfile(of: authResult.user, name: authResult.user.displayName ?? "")
    }

    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        try? Auth.auth().signOut()
    }

    /// Enregistre le profil dans Cloud Firestore : users/{uid}
    private func saveProfile(of user: User, name: String) async throws {
        try await Firestore.firestore().collection("users").document(user.uid).setData([
            "name": name,
            "email": user.email ?? "",
        ], merge: true)
    }

    /// Clé du message à afficher pour une erreur Firebase
    static func messageKey(for error: Error) -> String {
        switch AuthErrorCode(rawValue: (error as NSError).code) {
        case .invalidEmail: return "auth.error.invalidEmail"
        case .emailAlreadyInUse: return "auth.error.emailInUse"
        case .weakPassword: return "auth.error.weakPassword"
        case .wrongPassword, .userNotFound, .invalidCredential: return "auth.error.wrongCredentials"
        case .networkError: return "error.network.offline"
        default: return "error.unknown"
        }
    }
}
