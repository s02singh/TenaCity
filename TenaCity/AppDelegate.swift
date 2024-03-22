import UIKit
import Firebase
import GoogleSignIn
import FirebaseCore
import FirebaseFirestore

class AppDelegate: NSObject, UIApplicationDelegate {
    // Function calls on launch. configures our firebase.
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
    
    // Function called when the app is opened with a URL.
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any])
    -> Bool {
        // namely it will allow us to signin with google using the shared instance
        return GIDSignIn.sharedInstance.handle(url)
    }
}



