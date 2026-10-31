import UIKit
import FirebaseCore
import GoogleMobileAds

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // Pendant les tests unitaires, on ne démarre pas les SDK (tests rapides et hors ligne)
        guard !AppDelegate.isRunningTests else { return true }

        configureFirebase()
        MobileAds.shared.start(completionHandler: nil)
        return true
    }

    private func configureFirebase() {
        guard Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil else {
            print("⚠️ GoogleService-Info.plist manquant : Firebase n'est pas configuré (voir README).")
            return
        }
        FirebaseApp.configure()
    }

    static var isRunningTests: Bool {
        ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
    }
}
