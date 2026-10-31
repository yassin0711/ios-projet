import UIKit
import GoogleMobileAds

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // Démarre le SDK des publicités Google (identifiants de test, voir project.yml)
        MobileAds.shared.start(completionHandler: nil)
        return true
    }
}
