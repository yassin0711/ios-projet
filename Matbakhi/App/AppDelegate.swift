import UIKit
import GoogleMobileAds

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // Démarre le SDK des publicités Google (identifiant de test dans Info.plist, voir README)
        MobileAds.shared.start(completionHandler: nil)
        return true
    }
}
